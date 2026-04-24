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
        @contacts.map do |c|
          {
            name: c.full_name,
            emails: c.emails,
            phones: c.phones,
            company: c.company
          }
        end
      end
    end
  end
end
