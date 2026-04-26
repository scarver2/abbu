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
        [
          contact.full_name,
          contact.emails.first&.fetch(:address, nil),
          contact.phones.first&.fetch(:number, nil),
          contact.company,
          format_address(contact.addresses.first),
          contact.groups.join(', '),
          contact.urls.map { |u| u[:url] }.join(', '),
          contact.notes.join("\n"),
          contact.related_names.map { |rn| "#{rn[:name]} (#{rn[:label]})" }.join(', '),
          contact.social_profiles.map { |sp| "#{sp[:username]} on #{sp[:service]}" }.join(', ')
        ]
      end

      def format_address(addr)
        return nil unless addr

        [addr[:street], addr[:city], addr[:state], addr[:zip], addr[:country]].compact.join(', ')
      end
    end
  end
end
