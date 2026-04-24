<!-- README.md -->

# abbu

Read and process Apple Contacts `.abbu` archives in Ruby.

## Features

- Parse ABBU (Apple Contacts export) bundles
- SQLite-backed contact extraction (modern macOS)
- Legacy plist format detection (stub, v0.2 roadmap)
- Export to CSV, JSON, vCard
- CLI + Ruby API
- Duplicate detection

## Installation

```bash
gem install abbu
```

Or add to your `Gemfile`:

```ruby
gem "abbu"
```

## Usage

### Ruby API

```ruby
require "abbu"

archive = Abbu.open("Contacts.abbu")
contacts = archive.contacts

contacts.first.full_name   # => "Stan Carver"
contacts.first.emails      # => ["stan@example.com"]
contacts.first.phones      # => ["555-1234"]
```

### Export

```ruby
# CSV
Abbu::Exporters::CsvExporter.new(archive.contacts).to_file("contacts.csv")

# JSON
Abbu::Exporters::JsonExporter.new(archive.contacts).to_file("contacts.json")

# vCard
Abbu::Exporters::VcardExporter.new(archive.contacts).to_file("contacts.vcf")
```

### Duplicate Detection

```ruby
dupes = Abbu::Utils::Deduplicator.new(archive.contacts).duplicates
dupes.each do |email, contacts|
  puts "Duplicate: #{email}"
  contacts.each { |c| puts "  - #{c.full_name}" }
end
```

## CLI

```bash
# Export to CSV
abbu Contacts.abbu -f csv -o contacts.csv

# JSON to stdout (pipeable)
abbu Contacts.abbu -f json | jq .

# vCard export
abbu Contacts.abbu -f vcard -o contacts.vcf

# Stats
abbu Contacts.abbu --stats

# Find duplicates
abbu Contacts.abbu --dedupe
```

## Rake Tasks

```ruby
# In your Rakefile:
load "tasks/abbu.rake"
```

```bash
rake abbu:export[Contacts.abbu]
rake abbu:dedupe[Contacts.abbu]
rake abbu:stats[Contacts.abbu]
```

## ABBU File Format

See [`docs/ABBU.md`](docs/ABBU.md) for a full explanation of the archive structure,
SQLite table schema, and format history.

## Roadmap

| Version | Features                                    |
|---------|---------------------------------------------|
| v0.1.0  | SQLite parsing, CSV/JSON/vCard export, CLI  |
| v0.2.0  | Plist parser, image extraction              |
| v0.3.0  | Fuzzy dedupe (Levenshtein), merge engine    |
| v1.0.0  | Sync adapters (Printavo, HubSpot, CRM)      |

## Development

```bash
mise exec -- bundle install
mise exec -- bundle exec guard    # DX loop: auto-test + auto-lint
mise exec -- bundle exec rspec    # run specs
mise exec -- bundle exec rubocop  # lint
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).

---
Stan Carver II
Made in Texas 🤠
https://stancarver.com
