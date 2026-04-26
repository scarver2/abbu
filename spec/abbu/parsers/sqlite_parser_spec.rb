# spec/abbu/parsers/sqlite_parser_spec.rb
# frozen_string_literal: true

require 'sqlite3'
require 'tmpdir'

RSpec.describe Abbu::Parsers::SqliteParser do
  def create_schema(db)
    db.execute('CREATE TABLE ZABCDRECORD ' \
               '(Z_PK INTEGER PRIMARY KEY, Z_ENT INTEGER, ZFIRSTNAME TEXT, ZLASTNAME TEXT, ZNICKNAME TEXT, ZTITLE TEXT, ZSUFFIX TEXT, ZORGANIZATION TEXT, ' \
               'ZJOBTITLE TEXT, ZDEPARTMENT TEXT, ZMAIDENNAME TEXT, ZPHONETICFIRSTNAME TEXT, ZPHONETICLASTNAME TEXT, ZPHONETICORGANIZATION TEXT, ' \
               'ZPRONOUNS TEXT, ZRINGTONE TEXT, ZTEXTTONE TEXT)')
    db.execute('CREATE TABLE ZABCDEMAILADDRESS ' \
               '(Z_PK INTEGER PRIMARY KEY, ZOWNER INTEGER, ZADDRESSNORMALIZED TEXT, ZLABEL TEXT)')
    db.execute('CREATE TABLE ZABCDPHONENUMBER ' \
               '(Z_PK INTEGER PRIMARY KEY, ZOWNER INTEGER, ZFULLNUMBER TEXT, ZLABEL TEXT)')
    db.execute('CREATE TABLE ZABCDPOSTALADDRESS ' \
               '(Z_PK INTEGER PRIMARY KEY, ZOWNER INTEGER, ZSTREET TEXT, ZCITY TEXT, ZSTATE TEXT, ZZIPCODE TEXT, ZCOUNTRYNAME TEXT, ZLABEL TEXT)')
    db.execute('CREATE TABLE Z_ABCDCONTACTGROUP ' \
               '(Z_CONTACT INTEGER, Z_GROUP INTEGER)')
  end

  def build_test_db(path)
    db = SQLite3::Database.new(path)
    create_schema(db)
    db.execute("INSERT INTO ZABCDRECORD VALUES (1, 14, 'Stan', 'Carver', 'Stretch', 'Honorable', 'II', 'Acme', 'Engineer', 'IT', 'Smith', 'Stan', 'Karver', 'Akme', 'he/him', 'Marimba', 'Ding')")
    db.execute("INSERT INTO ZABCDEMAILADDRESS VALUES (1, 1, 'stan@example.com', 'Work')")
    db.execute("INSERT INTO ZABCDPHONENUMBER VALUES (1, 1, '555-1234', 'Mobile')")
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
        expect(contacts.first.emails).to     eq([{ address: 'stan@example.com', label: 'Work' }])
        expect(contacts.first.phones).to     eq([{ number: '555-1234', label: 'Mobile' }])
        expect(contacts.first.job_title).to  eq('Engineer')
        expect(contacts.first.department).to eq('IT')
        expect(contacts.first.maiden_name).to eq('Smith')
        expect(contacts.first.phonetic_first_name).to eq('Stan')
        expect(contacts.first.phonetic_last_name).to eq('Karver')
        expect(contacts.first.phonetic_company).to eq('Akme')
        expect(contacts.first.pronouns).to eq('he/him')
        expect(contacts.first.ringtone).to eq('Marimba')
        expect(contacts.first.texttone).to eq('Ding')
      end
    end

    it 'returns empty arrays for contacts with no emails or phones' do
      Dir.mktmpdir do |dir|
        db_path = File.join(dir, 'AddressBook-v22.abcddb')
        db = SQLite3::Database.new(db_path)
        create_schema(db)
        db.execute("INSERT INTO ZABCDRECORD (Z_PK, Z_ENT, ZFIRSTNAME) VALUES (1, 14, 'Ghost')")
        db.close

        parser   = described_class.new(Pathname.new(db_path))
        contacts = parser.contacts

        expect(contacts.first.emails).to eq([])
        expect(contacts.first.phones).to eq([])
      end
    end

    it 'returns empty groups when Z_ABCDCONTACTGROUP does not exist' do
      Dir.mktmpdir do |dir|
        db_path = File.join(dir, 'AddressBook-v22.abcddb')
        db = SQLite3::Database.new(db_path)
        create_schema(db)
        db.execute('DROP TABLE Z_ABCDCONTACTGROUP')
        db.execute("INSERT INTO ZABCDRECORD (Z_PK, Z_ENT, ZFIRSTNAME) VALUES (1, 14, 'Ghost')")
        db.close

        parser   = described_class.new(Pathname.new(db_path))
        contacts = parser.contacts

        expect(contacts.first.groups).to eq([])
      end
    end
  end
end
