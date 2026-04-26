# lib/abbu/exporters/json_exporter.rb
# frozen_string_literal: true

require 'json'

module Abbu
  module Exporters
    class JsonExporter
      def initialize(contacts)
        @contacts = contacts
      end

      def to_file(path)
        File.write(path, JSON.pretty_generate(payload))
      end

      def to_stdout
        puts JSON.pretty_generate(payload)
      end

      private

      def payload
        @contacts.map { |c| contact_hash(c) }
      end

      def contact_hash(contact) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        {
          name: contact.full_name,
          first_name: contact.first_name,
          last_name: contact.last_name,
          nickname: contact.nickname,
          prefix: contact.prefix,
          suffix: contact.suffix,
          company: contact.company,
          job_title: contact.job_title,
          department: contact.department,
          emails: contact.emails,
          phones: contact.phones,
          addresses: contact.addresses,
          groups: contact.groups,
          urls: contact.urls,
          notes: contact.notes,
          related_names: contact.related_names,
          social_profiles: contact.social_profiles
        }.compact
      end
    end
  end
end
