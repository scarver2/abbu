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
        # Exclude groups (typically Z_ENT = 15 in this schema version)
        db.execute('SELECT * FROM ZABCDRECORD WHERE Z_ENT != 15')
      end

      def emails_for(db, record_id)
        db.execute(
          'SELECT ZADDRESSNORMALIZED, ZLABEL FROM ZABCDEMAILADDRESS WHERE ZOWNER = ?',
          record_id
        ).map { |row| { address: row['ZADDRESSNORMALIZED'], label: row['ZLABEL'] } }
      end

      def phones_for(db, record_id)
        db.execute(
          'SELECT ZFULLNUMBER, ZLABEL FROM ZABCDPHONENUMBER WHERE ZOWNER = ?',
          record_id
        ).map { |row| { number: row['ZFULLNUMBER'], label: row['ZLABEL'] } }
      end

      def addresses_for(db, record_id)
        db.execute(
          'SELECT ZSTREET, ZCITY, ZSTATE, ZZIPCODE, ZCOUNTRYNAME, ZLABEL FROM ZABCDPOSTALADDRESS WHERE ZOWNER = ?',
          record_id
        ).map do |row|
          {
            street: row['ZSTREET'],
            city: row['ZCITY'],
            state: row['ZSTATE'],
            zip: row['ZZIPCODE'],
            country: row['ZCOUNTRYNAME'],
            label: row['ZLABEL']
          }
        end
      end

      def groups_for(db, record_id)
        # In our simplified schema, Z_ABCDCONTACTGROUP joins to ZABCDRECORD
        query = <<-SQL
          SELECT g.ZFIRSTNAME
          FROM Z_ABCDCONTACTGROUP j
          JOIN ZABCDRECORD g ON j.Z_GROUP = g.Z_PK
          WHERE j.Z_CONTACT = ?
        SQL
        db.execute(query, record_id).map { |row| row['ZFIRSTNAME'] }
      rescue SQLite3::SQLException
        # If the join table doesn't exist in a real DB, just return empty
        []
      end

      def build_contact(db, row)
        contact = Contact.new
        contact.first_name = row['ZFIRSTNAME']
        contact.last_name  = row['ZLASTNAME']
        contact.nickname   = row['ZNICKNAME']
        contact.prefix     = row['ZTITLE']
        contact.suffix     = row['ZSUFFIX']
        contact.company    = row['ZORGANIZATION']
        contact.emails     = emails_for(db, row['Z_PK'])
        contact.phones     = phones_for(db, row['Z_PK'])
        contact.addresses  = addresses_for(db, row['Z_PK'])
        contact.groups     = groups_for(db, row['Z_PK'])
        contact
      end
    end
  end
end
