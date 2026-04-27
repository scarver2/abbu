# spec/abbu/parsers/plist_parser_spec.rb
# frozen_string_literal: true

require 'plist'
require 'tmpdir'

RSpec.describe Abbu::Parsers::PlistParser do
  def write_plist(dir, filename, data)
    File.write(File.join(dir, filename), data.to_plist)
  end

  def build_stan_plist # rubocop:disable Metrics/MethodLength
    {
      'First' => 'Stan',
      'Last' => 'Carver',
      'Organization' => 'Acme Corp',
      'JobTitle' => 'Engineer',
      'Department' => 'IT',
      'Nickname' => 'Stretch',
      'Title' => 'Honorable',
      'Suffix' => 'II',
      'Note' => 'Met at RubyConf',
      'Email' => {
        'values' => [
          { 'value' => 'stan@example.com', 'label' => 'Work' }
        ]
      },
      'Phone' => {
        'values' => [
          { 'value' => '555-1234', 'label' => 'Mobile' }
        ]
      },
      'Address' => {
        'values' => [
          {
            'value' => {
              'Street' => '123 Main St',
              'City' => 'Austin',
              'State' => 'TX',
              'ZIP' => '78701',
              'Country' => 'USA'
            },
            'label' => 'Home'
          }
        ]
      },
      'URLs' => {
        'values' => [
          { 'value' => 'https://stancarver.com', 'label' => 'homepage' }
        ]
      },
      'RelatedNames' => {
        'values' => [
          { 'value' => 'John', 'label' => 'brother' }
        ]
      },
      'SocialProfile' => {
        'values' => [
          { 'value' => { 'serviceName' => 'Twitter', 'username' => '@scarver2' } }
        ]
      }
    }
  end

  describe '#contacts' do
    it 'parses flat and multi-value fields from .abcdp files' do
      Dir.mktmpdir do |dir|
        write_plist(dir, 'stan.abcdp', build_stan_plist)

        parser  = described_class.new(dir)
        contact = parser.contacts.first

        # Flat fields
        expect(contact.first_name).to eq('Stan')
        expect(contact.last_name).to  eq('Carver')
        expect(contact.company).to    eq('Acme Corp')
        expect(contact.job_title).to  eq('Engineer')
        expect(contact.department).to eq('IT')
        expect(contact.nickname).to   eq('Stretch')
        expect(contact.prefix).to     eq('Honorable')
        expect(contact.suffix).to     eq('II')

        # Emails & phones (hash-based, same shape as SQLite parser)
        expect(contact.emails).to eq([{ address: 'stan@example.com', label: 'Work' }])
        expect(contact.phones).to eq([{ number: '555-1234', label: 'Mobile' }])

        # Addresses
        expect(contact.addresses).to eq([{
                                          street: '123 Main St', city: 'Austin', state: 'TX',
                                          zip: '78701', country: 'USA', label: 'Home'
                                        }])

        # URLs
        expect(contact.urls).to eq([{ url: 'https://stancarver.com', label: 'homepage' }])

        # Notes
        expect(contact.notes).to eq(['Met at RubyConf'])

        # Related names
        expect(contact.related_names).to eq([{ name: 'John', label: 'brother' }])

        # Social profiles
        expect(contact.social_profiles).to eq([{ service: 'Twitter', username: '@scarver2' }])
      end
    end

    it 'parses multiple .abcdp files in sorted order' do
      Dir.mktmpdir do |dir|
        write_plist(dir, 'b_homer.abcdp', { 'First' => 'Homer', 'Last' => 'Simpson' })
        write_plist(dir, 'a_stan.abcdp', { 'First' => 'Stan', 'Last' => 'Carver' })

        parser   = described_class.new(dir)
        contacts = parser.contacts

        expect(contacts.size).to eq(2)
        expect(contacts.first.first_name).to eq('Stan')
        expect(contacts.last.first_name).to eq('Homer')
      end
    end

    it 'returns empty array when path does not exist' do
      parser = described_class.new('/nonexistent/path/Records')
      expect(parser.contacts).to eq([])
    end

    it 'returns empty array when directory has no .abcdp files' do
      Dir.mktmpdir do |dir|
        parser = described_class.new(dir)
        expect(parser.contacts).to eq([])
      end
    end

    it 'handles contacts with minimal data gracefully' do
      Dir.mktmpdir do |dir|
        write_plist(dir, 'minimal.abcdp', { 'First' => 'Prince' })

        parser  = described_class.new(dir)
        contact = parser.contacts.first

        expect(contact.first_name).to eq('Prince')
        expect(contact.last_name).to be_nil
        expect(contact.emails).to eq([])
        expect(contact.phones).to eq([])
        expect(contact.addresses).to eq([])
        expect(contact.notes).to eq([])
      end
    end
  end
end
