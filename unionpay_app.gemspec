# -*- encoding: utf-8 -*-
# stub: unionpay_app 0.10.0 ruby lib

Gem::Specification.new do |s|
  s.name = "unionpay_app"
  s.version = "0.10.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Yohansun"]
  s.date = "2015-11-18"
  s.description = "An unofficial simple unionpay_app gem"
  s.email = ["yohansun@qq.com"]
  s.files = ["Gemfile", "Gemfile.lock", "README.md", "lib/unionpay_app.rb", "lib/unionpay_app/service.rb", "lib/unionpay_app/version.rb", "tmp", "unionpay_app.gemspec"]
  s.homepage = "https://github.com/Yohansun/unionpay_app"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.4.5"
  s.summary = "An unofficial simple unionpay_app gem"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<fakeweb>, [">= 0"])
    else
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<fakeweb>, [">= 0"])
    end
  else
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<fakeweb>, [">= 0"])
  end
end
