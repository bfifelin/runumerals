# -*- encoding: utf-8 -*-

require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "runumerals".freeze
  s.version     = RuNumerals::VERSION
  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.date        = "2018-05-15"
  s.summary     = "Russian numerals".freeze
  s.description = "Convertation of numeric values to russian numerals".freeze
  s.authors     = ["Sergey Abel".freeze,"Boris Fifelin".freeze]
  s.email       = "bfifelin@gmail.com".freeze
  s.homepage    = "https://github.com/bfifelin/runumerals".freeze
  s.licenses       = ["MIT".freeze]
  s.files       = Dir.glob("lib/*") + %w{ LICENSE README.md Rakefile .yardopts }
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2".freeze)
  s.rubygems_version = "2.6.11".freeze
  s.installed_by_version = "2.6.11" if s.respond_to? :installed_by_version
  if s.respond_to? :specification_version then
    s.specification_version = 4
    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<yard>.freeze, [">= 0"])
      s.add_development_dependency(%q<rake>.freeze, [">= 0"])
      s.add_development_dependency(%q<test-unit>.freeze, [">= 0"])
    else
      s.add_dependency(%q<yard>.freeze, [">= 0"])
      s.add_dependency(%q<rake>.freeze, [">= 0"])
      s.add_dependency(%q<test-unit>.freeze, [">= 0"])
    end
  else
    s.add_dependency(%q<yard>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<test-unit>.freeze, [">= 0"])
  end
end