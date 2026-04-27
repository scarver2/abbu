# lib/abbu/parsers/plist_parser.rb
# frozen_string_literal: true

require 'plist'
require_relative '../contact'

module Abbu
  module Parsers
    class PlistParser
      # Maps plist keys → Contact attr_accessor names for simple string fields
      FIELD_MAP = {
        'First' => :first_name,   'Last' => :last_name,
        'Nickname' => :nickname,  'Title' => :prefix,
        'Suffix' => :suffix,      'Organization' => :company,
        'JobTitle' => :job_title, 'Department' => :department,
        'MaidenName' => :maiden_name
      }.freeze

      # Accepts either a directory path (scans for *.abcdp) or an array of file paths
      def initialize(paths)
        @paths = resolve_paths(paths)
      end

      def contacts
        @paths.filter_map { |file| parse_file(file) }
      end

      private

      def resolve_paths(paths)
        case paths
        when Array
          paths.map { |p| Pathname.new(p) }
        else
          path = Pathname.new(paths)
          return [] unless path.exist?

          path.directory? ? path.glob('*.abcdp').sort : [path]
        end
      end

      def parse_file(file)
        data = Plist.parse_xml(file.to_s)
        return nil unless data

        build_contact(data)
      end

      def build_contact(data)
        contact = Contact.new
        assign_flat_fields(contact, data)
        assign_multi_value_fields(contact, data)
        contact
      end

      def assign_flat_fields(contact, data)
        FIELD_MAP.each do |plist_key, attr|
          contact.public_send(:"#{attr}=", data[plist_key])
        end
      end

      def assign_multi_value_fields(contact, data)
        contact.emails          = extract_labeled_values(data, 'Email', :address)
        contact.phones          = extract_labeled_values(data, 'Phone', :number)
        contact.addresses       = extract_addresses(data)
        contact.urls            = extract_labeled_values(data, 'URLs', :url)
        contact.notes           = extract_notes(data)
        contact.related_names   = extract_labeled_values(data, 'RelatedNames', :name)
        contact.social_profiles = extract_social_profiles(data)
      end

      def extract_labeled_values(data, key, value_key)
        return [] unless data[key]&.dig('values')

        data[key]['values'].map do |entry|
          { value_key => entry['value'], label: entry['label'] }
        end
      end

      def extract_addresses(data) # rubocop:disable Metrics/MethodLength
        return [] unless data['Address']&.dig('values')

        data['Address']['values'].map do |entry|
          addr = entry['value'] || {}
          {
            street: addr['Street'],
            city: addr['City'],
            state: addr['State'],
            zip: addr['ZIP'],
            country: addr['Country'],
            label: entry['label']
          }
        end
      end

      def extract_notes(data)
        note = data['Note']
        note ? [note] : []
      end

      def extract_social_profiles(data)
        return [] unless data['SocialProfile']&.dig('values')

        data['SocialProfile']['values'].map do |entry|
          profile = entry['value'] || {}
          { service: profile['serviceName'], username: profile['username'] }
        end
      end
    end
  end
end
