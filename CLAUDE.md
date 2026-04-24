# CLAUDE.md

This file provides project-specific context and conventions to optimize AI assistant workflows in the `abbu` repository.

## Commands
* **Run Tests**: `bundle exec rspec`
* **Run Linting**: `bundle exec rubocop`
* **Run Linting (Auto-fix)**: `bundle exec rubocop -A`
* **Build Gem**: `gem build abbu.gemspec`
* **Release Gem**: `bundle exec rake release`

## Architecture & Design
* **Parsers**: Found in `lib/abbu/parsers`. Responsible for directly parsing specific storage formats (SQLite, Plist). Parsers MUST return an array of `Abbu::Contact` instances.
* **Exporters**: Found in `lib/abbu/exporters`. Responsible for taking an array of `Abbu::Contact` instances and serializing them into specific formats (CSV, JSON, vCard).
* **Archive**: Found in `lib/abbu/archive.rb`. Acts as the primary entry point to load an `.abbu` package. It dynamically discovers databases (including `Sources/` directories for synced contacts) and assigns the correct parser.

## Conventions
* **Isolated Requires**: When adding new standard libraries to a class, always `require` them directly inside the file where they are used (e.g., `require 'pathname'` in `archive.rb`), rather than relying on global requires in `lib/abbu.rb`. This prevents `NameError` bugs when components are loaded dynamically or in isolation.
* **Code Style**:
  * Adhere to RuboCop strictness (we use `rubocop-performance` and `rubocop-rake`).
  * Always use `frozen_string_literal: true` at the top of Ruby files.
  * Supports Ruby versions `3.2`, `3.3`, `3.4`, and `4.0`.
  * RuboCop targets Ruby version `3.2`.
* **Testing**:
  * Use RSpec. Write isolated unit tests for parsers and exporters.
  * Any bug fix should include a regression guard spec (if applicable).
