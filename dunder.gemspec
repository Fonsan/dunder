# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{dunder}
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Fonsan"]
  s.date = %q{2011-01-26}
  s.description = %q{For tasks that can be started early and evaluated late.

  Typically one might want start multiple heavy tasks concurrent.
  This is already solvable with threads or the [reactor-pattern](http://rubyeventmachine.com/) but setting this up could be cumbersome or require direct interactions with threads ex.

  Dunder is a simple way of abstracting this:
  you simply pass a block to Dunder.load with the expected class as the argument}
  s.email = %q{fonsan@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE.txt"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "Rakefile",
    "Readme.md",
    "VERSION",
    "dunder.gemspec",
    "lib/dunder.rb",
    "test/helper.rb",
    "test/test_dunder.rb"
  ]
  s.homepage = %q{http://github.com/Fonsan/dunder}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A simple way of doing heavy work in a background process and when you really need the object it will block until it is done}
  s.test_files = [
    "test/helper.rb",
    "test/test_dunder.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 3.0.3"])
      s.add_runtime_dependency(%q<activerecord>, [">= 3.0.3"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<activesupport>, [">= 3.0.3"])
      s.add_dependency(%q<activerecord>, [">= 3.0.3"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 3.0.3"])
    s.add_dependency(%q<activerecord>, [">= 3.0.3"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

