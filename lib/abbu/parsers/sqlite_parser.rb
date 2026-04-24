# lib/abbu/parsers/sqlite_parser.rb
# frozen_string_literal: true

require 'sqlite3'
require_relative '../contact'

module Abbu
  module Parsers
    class SqliteParser
      def initialize(db_paths)
        @db_paths = Array(db_paths)
      end

      def contacts
        @db_paths.flat_map do |db_path|
          parse_db(db_path)
        end
      end

      private

      def parse_db(db_path)
        db = SQLite3::Database.new(db_path.to_s)
        db.results_as_hash = true
        records(db).map { |row| build_contact(db, row) }
      ensure
        db&.close
      end

      def records(db)
        db.execute('SELECT * FROM ZABCDRECORD')
      end

      def emails_for(db, record_id)
        db.execute(
          'SELECT ZADDRESSNORMALIZED FROM ZABCDEMAILADDRESS WHERE ZOWNER = ?',
          record_id
        ).filter_map { |row| row['ZADDRESSNORMALIZED'] }
      end

      def phones_for(db, record_id)
        db.execute(
          'SELECT ZFULLNUMBER FROM ZABCDPHONENUMBER WHERE ZOWNER = ?',
          record_id
        ).filter_map { |row| row['ZFULLNUMBER'] }
      end

      def build_contact(db, row)
        contact = Contact.new
        contact.first_name = row['ZFIRSTNAME']
        contact.last_name  = row['ZLASTNAME']
        contact.company    = row['ZORGANIZATION']
        contact.emails     = emails_for(db, row['Z_PK'])
        contact.phones     = phones_for(db, row['Z_PK'])
        contact
      end
    end
  end
end
