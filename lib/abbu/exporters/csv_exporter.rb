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
        %w[Name Email Phone Company]
      end

      def row(contact)
        [contact.full_name, contact.emails.first, contact.phones.first, contact.company]
      end
    end
  end
end
