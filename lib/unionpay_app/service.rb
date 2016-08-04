require 'digest'
require 'openssl'
require "base64"
require 'open-uri'
require 'typhoeus'

module UnionpayApp
  module Service
    #银联支付签名
    def self.sign txtAmt, orderId, expiredAt=nil, createAt=nil
      union_params = {
        :version => "5.0.0",
        :encoding => "utf-8",
        :certId => UnionpayApp.cert_id,
        :txnType => '01',
        :txnSubType => "01",
        :bizType => "000201",
        :channelType => "08",
        :frontUrl   => UnionpayApp.front_url,
        :backUrl    => UnionpayApp.back_url,
        :accessType => "0",
        :merId      => UnionpayApp.mer_id,
        :orderId => orderId,  #商户订单号
        :txnTime => (createAt||Time.now).strftime("%Y%m%d%H%M%S"),  #订单发送时间
        :txnAmt  => txtAmt, #以分为单位
        :currencyCode => '156',
        :signMethod => '01',
      }

      union_params[:payTimeout] = expiredAt.strftime("%Y%m%d%H%M%S") unless expiredAt.nil?

      data = Digest::SHA1.hexdigest(union_params.sort.map{|key, value| "#{key}=#{value}" }.join('&'))
      sign = Base64.encode64(OpenSSL::PKey::RSA.new(UnionpayApp.private_key).sign('sha1', data.force_encoding("utf-8"))).gsub("\n", "")
      {time: union_params[:txnTime], sign: union_params.merge(signature: sign)}
    end

    def self.post union_params
    	request = Typhoeus::Request.new(UnionpayApp.uri, method: :post, params: union_params[:sign], ssl_verifypeer: false, headers: {'Content-Type' =>'application/x-www-form-urlencoded'} )
      request.run
      if request.response.success?
        tn = Hash[*request.response.body.split("&").map{|a| a.gsub("==", "@@").split("=")}.flatten]['tn']
      else
        tn = ""
      end
    end

    #银联支付验签
    def self.verify params
      public_key = get_public_key_by_cert_id params['certId']
      return false if public_key.nil?

      signature_str = params['signature']
      p = params.reject{|k, v| k == "signature"}.sort.map{|key, value| "#{key}=#{value}" }.join('&')
      signature = Base64.decode64(signature_str)
      data = Digest::SHA1.hexdigest(p)
      digest = OpenSSL::Digest::SHA1.new
      public_key.verify digest, signature, data
    end

    # 银联支付 根据证书id返回公钥
    def self.get_public_key_by_cert_id cert_id
    	certificate = OpenSSL::X509::Certificate.new(UnionpayApp.cer) #读取cer文件
    	certificate.serial.to_s == cert_id ? certificate.public_key : nil #php 返回的直接是cer文件 UnionpayApp.cer
    end

    def self.query order_id, txnTime
    	union_params = {
        :version => '5.0.0',		#版本号
        :encoding => 'utf-8',		#编码方式
        :certId => UnionpayApp.cert_id,	#证书ID	
        :signMethod => '01',		#签名方法
        :txnType => '00',		#交易类型	
        :txnSubType => '00',		#交易子类
        :bizType => '000000',		#业务类型
        :accessType => '0',		#接入类型
        :channelType => '07',		#渠道类型
        :orderId => order_id,	#请修改被查询的交易的订单号
        :merId => UnionpayApp.mer_id,	#商户代码，请修改为自己的商户号
        :txnTime => txnTime,	#请修改被查询的交易的订单发送时间
    	}
    	data = Digest::SHA1.hexdigest(union_params.sort.map{|key, value| "#{key}=#{value}" }.join('&'))
      sign = Base64.encode64(OpenSSL::PKey::RSA.new(UnionpayApp.private_key).sign('sha1', data.force_encoding("utf-8"))).gsub("\n", "")
      request = Typhoeus::Request.new(UnionpayApp.query_uri, method: :post, params: union_params.merge(signature: sign), ssl_verifypeer: false, headers: {'Content-Type' =>'application/x-www-form-urlencoded'} )
      request.run
      if request.response.success?
        code = Hash[*request.response.body.split("&").map{|a| a.gsub("==", "@@").split("=")}.flatten]['origRespCode']
      elsif request.response.timed_out?
        code = "got a time out"
      elsif request.response.code == 0
        code = request.response.return_message
      else
        code = request.response.code.to_s
      end
    end

  end
end
