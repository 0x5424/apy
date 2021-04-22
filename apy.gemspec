# frozen_string_literal: true

require_relative "lib/apy/version"
require "date"

Gem::Specification.new do |gemspec|
  gemspec.name = "apy"
  gemspec.version = Apy::VERSION
  gemspec.authors = ["Trevor James"]
  gemspec.email = ["trevor@osrs-stat.com"]

  gemspec.summary = "Interest calculators"
  gemspec.description = "Helpers for calculating various interest scenarios"
  gemspec.homepage = "https://github.com/fire-pls/apy"
  gemspec.license = "MIT"
  gemspec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  gemspec.metadata["homepage_uri"] = gemspec.homepage
  gemspec.metadata["source_code_uri"] = gemspec.homepage
  gemspec.metadata["changelog_uri"] = [gemspec.homepage, "CHANGELOG"].join("/")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  gemspec.bindir = "exe"
  gemspec.executables = gemspec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  gemspec.require_paths = ["lib"]

  # Dependencies
  # None :)

  # Dev Dependencies
  gemspec.add_development_dependency "pry-byebug"
  gemspec.add_development_dependency "rake"
  gemspec.add_development_dependency "minitest", "~> 5.0"
  gemspec.add_development_dependency "standard"
end
