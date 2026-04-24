# abbu.gemspec
# frozen_string_literal: true

require_relative "lib/abbu/version"

Gem::Specification.new do |spec|
  spec.name        = "abbu"
  spec.version     = Abbu::VERSION
  spec.authors     = ["Stan Carver II"]
  spec.email       = ["stan@stancarver.com"]

  spec.summary     = "Read and process Apple Contacts .abbu archives in Ruby."
  spec.description = "Parse Apple Address Book Archive (.abbu) files and export contacts to CSV, JSON, or vCard. " \
                     "Supports modern SQLite-backed archives and legacy plist-based records."
  spec.homepage    = "https://github.com/scarver2/abbu"
  spec.license     = "MIT"

  spec.required_ruby_version = ">= 3.2"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"]   = "#{spec.homepage}/blob/master/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir[
    "lib/**/*.rb",
    "bin/*",
    "docs/**/*",
    "examples/**/*.rb",
    "tasks/**/*.rake",
    "LICENSE",
    "README.md",
    "CHANGELOG.md"
  ]

  spec.bindir        = "bin"
  spec.executables   = ["abbu"]
  spec.require_paths = ["lib"]

  spec.add_dependency "sqlite3", "~> 2.0"
  spec.add_dependency "csv"

  spec.add_development_dependency "guard",              "~> 2.18"
  spec.add_development_dependency "guard-rspec",        "~> 4.7"
  spec.add_development_dependency "guard-rubocop",      "~> 1.5"
  spec.add_development_dependency "rspec",              "~> 3.13"
  spec.add_development_dependency "rubocop",            "~> 1.65"
  spec.add_development_dependency "rubocop-performance", "~> 1.21"
  spec.add_development_dependency "rubocop-rake",       "~> 0.6"
  spec.add_development_dependency "simplecov",          "~> 0.22"
end
