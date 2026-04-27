<!-- CHANGELOG.md -->

# Changelog

All notable changes to `abbu` are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

## [0.1.2] - 2026-04-26

### Added

- Full Apple Contacts schema support: job title, department, maiden name, phonetic names, pronouns, ringtone, texttone
- Relational table parsing: URLs, notes, related names (family/business), social profiles (Twitter, etc.)
- Nickname, prefix, and suffix fields with smart `full_name` formatting
- Hash-based email/phone data preserving custom labels (e.g. "Direct Line", "Work")
- Address, group, URL, notes, related names, and social profiles in CSV export
- Comprehensive JSON export with all contact fields
- vCard 3.0 export with ADR, URL, NICKNAME, TITLE, NOTE, X-SOCIALPROFILE
- `rubocop-rspec` plugin integration
- 100% line coverage across all 44 specs

### Changed

- Refactored `SqliteParser` to use `RECORD_FIELD_MAP` constant for maintainability
- Refactored `CsvExporter` into `core_fields`/`extended_fields` for cleaner ABC metrics
- All specs comply with rubocop-rspec conventions

## [0.1.1] - 2026-04-23

### Fixed

- `require 'pathname'` missing in `archive.rb` causing `NameError` in isolation
- Added regression guard spec for file require isolation


## [0.1.0] - 2026-04-12

### Added

- `Abbu.open(path)` entry point returning an `Archive`
- `Archive#contacts` — reads contacts from SQLite or falls back to plist stub
- `Archive#sqlite?` — detects modern `.abcddb` bundles
- `Contact` object with `first_name`, `last_name`, `emails`, `phones`, `company`, `full_name`
- `Parsers::SqliteParser` — queries `ZABCDRECORD`, `ZABCDEMAILADDRESS`, `ZABCDPHONENUMBER`
- `Parsers::PlistParser` — stub with warning (legacy `.abcdp` support in v0.2)
- `Exporters::CsvExporter` — `to_file` and `to_stdout`
- `Exporters::JsonExporter` — `to_file` and `to_stdout`
- `Exporters::VcardExporter` — `to_file` and `to_stdout` (vCard 3.0)
- `Utils::Deduplicator` — groups contacts by first email, returns duplicates hash
- `bin/abbu` CLI with `--format`, `--output`, `--stats`, `--dedupe`, `--version`
- Rake tasks: `abbu:export`, `abbu:dedupe`, `abbu:stats`
- Example scripts: CSV, JSON, vCard, API, CRM sync, stats, dedupe
- `docs/ABBU.md` — file format reference
- RSpec test suite with 100% coverage target
- Guard + RuboCop DX loop
- GitHub Actions CI (Ruby 3.2 + 3.3)

---
Stan Carver II
Made in Texas 🤠
https://stancarver.com
