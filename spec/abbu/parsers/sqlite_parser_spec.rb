# spec/abbu/parsers/sqlite_parser_spec.rb
# frozen_string_literal: true

require 'sqlite3'
require 'tmpdir'

RSpec.describe Abbu::Parsers::SqliteParser do
  def create_schema(db)
    db.execute('CREATE TABLE ZABCDRECORD ' \
               '(Z_PK INTEGER PRIMARY KEY, ZFIRSTNAME TEXT, ZLASTNAME TEXT, ZORGANIZATION TEXT)')
    db.execute('CREATE TABLE ZABCDEMAILADDRESS ' \
               '(Z_PK INTEGER PRIMARY KEY, ZOWNER INTEGER, ZADDRESSNORMALIZED TEXT)')
    db.execute('CREATE TABLE ZABCDPHONENUMBER ' \
               '(Z_PK INTEGER PRIMARY KEY, ZOWNER INTEGER, ZFULLNUMBER TEXT)')
  end

  def build_test_db(path)
    db = SQLite3::Database.new(path)
    create_schema(db)
    db.execute("INSERT INTO ZABCDRECORD VALUES (1, 'Stan', 'Carver', 'Acme')")
    db.execute("INSERT INTO ZABCDEMAILADDRESS VALUES (1, 1, 'stan@example.com')")
    db.execute("INSERT INTO ZABCDPHONENUMBER VALUES (1, 1, '555-1234')")
    db.close
  end

  describe '#contacts' do
    it 'returns contacts from the SQLite database' do
      Dir.mktmpdir do |dir|
        db_path = File.join(dir, 'AddressBook-v22.abcddb')
        build_test_db(db_path)

        parser   = described_class.new(Pathname.new(db_path))
        contacts = parser.contacts

        expect(contacts.size).to eq(1)
        expect(contacts.first.first_name).to eq('Stan')
        expect(contacts.first.last_name).to  eq('Carver')
        expect(contacts.first.company).to    eq('Acme')
        expect(contacts.first.emails).to     eq(['stan@example.com'])
        expect(contacts.first.phones).to     eq(['555-1234'])
      end
    end

    it 'returns empty arrays for contacts with no emails or phones' do
      Dir.mktmpdir do |dir|
        db_path = File.join(dir, 'AddressBook-v22.abcddb')
        db = SQLite3::Database.new(db_path)
        create_schema(db)
        db.execute("INSERT INTO ZABCDRECORD VALUES (1, 'Ghost', NULL, NULL)")
        db.close

        parser   = described_class.new(Pathname.new(db_path))
        contacts = parser.contacts

        expect(contacts.first.emails).to eq([])
        expect(contacts.first.phones).to eq([])
      end
    end
  end
end
