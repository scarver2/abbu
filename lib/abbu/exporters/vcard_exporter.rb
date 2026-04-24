# lib/abbu/exporters/vcard_exporter.rb
# frozen_string_literal: true

module Abbu
  module Exporters
    class VcardExporter
      def initialize(contacts)
        @contacts = contacts
      end

      def to_file(path)
        File.write(path, generate)
      end

      def to_stdout
        puts generate
      end

      private

      def generate
        @contacts.map { |c| vcard_for(c) }.join("\n")
      end

      def vcard_for(contact)
        lines = ['BEGIN:VCARD', 'VERSION:3.0']
        lines << "FN:#{contact.full_name}"
        lines << "N:#{contact.last_name};#{contact.first_name};;;"
        lines << "ORG:#{contact.company}" if contact.company
        contact.emails.each { |e| lines << "EMAIL:#{e}" }
        contact.phones.each { |p| lines << "TEL:#{p}" }
        lines << 'END:VCARD'
        lines.join("\n")
      end
    end
  end
end
