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

      def vcard_for(contact) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        lines = ['BEGIN:VCARD', 'VERSION:3.0']
        lines << "FN:#{contact.full_name}"
        lines << "N:#{contact.last_name};#{contact.first_name};;;"
        lines << "NICKNAME:#{contact.nickname}" if contact.nickname
        lines << "ORG:#{contact.company}" if contact.company
        lines << "TITLE:#{contact.job_title}" if contact.job_title
        append_emails(lines, contact)
        append_phones(lines, contact)
        append_addresses(lines, contact)
        append_urls(lines, contact)
        append_social_profiles(lines, contact)
        contact.notes.each { |n| lines << "NOTE:#{n}" }
        lines << 'END:VCARD'
        lines.join("\n")
      end

      def append_emails(lines, contact)
        contact.emails.each do |e|
          label = e[:label] || 'INTERNET'
          lines << "EMAIL;TYPE=#{label}:#{e[:address]}"
        end
      end

      def append_phones(lines, contact)
        contact.phones.each do |p|
          label = p[:label] || 'VOICE'
          lines << "TEL;TYPE=#{label}:#{p[:number]}"
        end
      end

      def append_addresses(lines, contact)
        contact.addresses.each do |a|
          label = a[:label] || 'HOME'
          lines << "ADR;TYPE=#{label}:;;#{a[:street]};#{a[:city]};#{a[:state]};#{a[:zip]};#{a[:country]}"
        end
      end

      def append_urls(lines, contact)
        contact.urls.each do |u|
          lines << "URL:#{u[:url]}"
        end
      end

      def append_social_profiles(lines, contact)
        contact.social_profiles.each do |sp|
          lines << "X-SOCIALPROFILE;TYPE=#{sp[:service]}:#{sp[:username]}"
        end
      end
    end
  end
end
