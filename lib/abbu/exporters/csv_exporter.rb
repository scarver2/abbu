# lib/abbu/exporters/csv_exporter.rb
# frozen_string_literal: true

require 'csv'

module Abbu
  module Exporters
    class CsvExporter
      def initialize(contacts)
        @contacts = contacts
      end

      def to_file(path)
        CSV.open(path, 'w') do |csv|
          csv << headers
          @contacts.each { |c| csv << row(c) }
        end
      end

      def to_stdout
        puts(CSV.generate do |csv|
          csv << headers
          @contacts.each { |c| csv << row(c) }
        end)
      end

      private

      def headers
        %w[Name Email Phone Company Address Groups URLs Notes RelatedNames SocialProfiles]
      end

      def row(contact)
        core_fields(contact) + extended_fields(contact)
      end

      def core_fields(contact)
        [
          contact.full_name,
          contact.emails.first&.fetch(:address, nil),
          contact.phones.first&.fetch(:number, nil),
          contact.company,
          format_address(contact.addresses.first),
          contact.groups.join(', ')
        ]
      end

      def extended_fields(contact)
        [
          contact.urls.map { |u| u[:url] }.join(', '),
          contact.notes.join("\n"),
          format_related_names(contact.related_names),
          format_social_profiles(contact.social_profiles)
        ]
      end

      def format_address(addr)
        return nil unless addr

        [addr[:street], addr[:city], addr[:state], addr[:zip], addr[:country]].compact.join(', ')
      end

      def format_related_names(names)
        names.map { |rn| "#{rn[:name]} (#{rn[:label]})" }.join(', ')
      end

      def format_social_profiles(profiles)
        profiles.map { |sp| "#{sp[:username]} on #{sp[:service]}" }.join(', ')
      end
    end
  end
end
