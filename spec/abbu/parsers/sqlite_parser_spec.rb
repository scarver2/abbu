# spec/abbu/parsers/sqlite_parser_spec.rb
# frozen_string_literal: true

require 'sqlite3'
require 'tmpdir'

RSpec.describe Abbu::Parsers::SqliteParser do
  def create_schema(db) # rubocop:disable Metrics/MethodLength
    db.execute <<-SQL
      CREATE TABLE ZABCDRECORD (
        Z_PK INTEGER PRIMARY KEY, Z_ENT INTEGER,
        ZFIRSTNAME TEXT, ZLASTNAME TEXT, ZNICKNAME TEXT,
        ZTITLE TEXT, ZSUFFIX TEXT, ZORGANIZATION TEXT,
        ZJOBTITLE TEXT, ZDEPARTMENT TEXT, ZMAIDENNAME TEXT,
        ZPHONETICFIRSTNAME TEXT, ZPHONETICLASTNAME TEXT,
        ZPHONETICORGANIZATION TEXT, ZPRONOUNS TEXT,
        ZRINGTONE TEXT, ZTEXTTONE TEXT
      )
    SQL
    db.execute <<-SQL
      CREATE TABLE ZABCDEMAILADDRESS (
        Z_PK INTEGER PRIMARY KEY, ZOWNER INTEGER,
        ZADDRESSNORMALIZED TEXT, ZLABEL TEXT
      )
    SQL
    db.execute <<-SQL
      CREATE TABLE ZABCDPHONENUMBER (
        Z_PK INTEGER PRIMARY KEY, ZOWNER INTEGER,
        ZFULLNUMBER TEXT, ZLABEL TEXT
      )
    SQL
    db.execute <<-SQL
      CREATE TABLE ZABCDPOSTALADDRESS (
        Z_PK INTEGER PRIMARY KEY, ZOWNER INTEGER,
        ZSTREET TEXT, ZCITY TEXT, ZSTATE TEXT,
        ZZIPCODE TEXT, ZCOUNTRYNAME TEXT, ZLABEL TEXT
      )
    SQL
    db.execute <<-SQL
      CREATE TABLE Z_ABCDCONTACTGROUP (
        Z_CONTACT INTEGER, Z_GROUP INTEGER
      )
    SQL
    db.execute <<-SQL
      CREATE TABLE ZABCDURLADDRESS (
        Z_PK INTEGER PRIMARY KEY, ZOWNER INTEGER,
        ZURL TEXT, ZLABEL TEXT
      )
    SQL
    db.execute <<-SQL
      CREATE TABLE ZABCDNOTE (
        Z_PK INTEGER PRIMARY KEY, ZCONTACT INTEGER,
        ZTEXT TEXT
      )
    SQL
    db.execute <<-SQL
      CREATE TABLE ZABCDRELATEDNAME (
        Z_PK INTEGER PRIMARY KEY, ZOWNER INTEGER,
        ZNAME TEXT, ZLABEL TEXT
      )
    SQL
    db.execute <<-SQL
      CREATE TABLE ZABCDSOCIALPROFILE (
        Z_PK INTEGER PRIMARY KEY, ZOWNER INTEGER,
        ZSERVICENAME TEXT, ZUSERNAME TEXT
      )
    SQL
  end

  def build_test_db(path) # rubocop:disable Metrics/MethodLength
    db = SQLite3::Database.new(path)
    create_schema(db)
    db.execute <<-SQL
      INSERT INTO ZABCDRECORD VALUES (
        1, 14, 'Stan', 'Carver', 'Stretch', 'Honorable', 'II',
        'Acme', 'Engineer', 'IT', 'Smith', 'Stan', 'Karver',
        'Akme', 'he/him', 'Marimba', 'Ding'
      )
    SQL
    db.execute("INSERT INTO ZABCDEMAILADDRESS VALUES (1, 1, 'stan@example.com', 'Work')")
    db.execute("INSERT INTO ZABCDPHONENUMBER VALUES (1, 1, '555-1234', 'Mobile')")
    db.execute("INSERT INTO ZABCDURLADDRESS VALUES (1, 1, 'https://stancarver.com', 'homepage')")
    db.execute("INSERT INTO ZABCDNOTE VALUES (1, 1, 'Met at RubyConf')")
    db.execute("INSERT INTO ZABCDRELATEDNAME VALUES (1, 1, 'John', 'brother')")
    db.execute("INSERT INTO ZABCDSOCIALPROFILE VALUES (1, 1, 'Twitter', '@scarver2')")
    db.close
  end

  describe '#contacts' do
    it 'parses all flat and relational fields from a SQLite database' do # rubocop:disable RSpec/MultipleExpectations
      Dir.mktmpdir do |dir|
        db_path = File.join(dir, 'AddressBook-v22.abcddb')
        build_test_db(db_path)

        parser   = described_class.new(Pathname.new(db_path))
        contact  = parser.contacts.first

        # Flat fields
        expect(contact.first_name).to eq('Stan')
        expect(contact.last_name).to  eq('Carver')
        expect(contact.company).to    eq('Acme')
        expect(contact.job_title).to  eq('Engineer')
        expect(contact.department).to eq('IT')
        expect(contact.maiden_name).to eq('Smith')
        expect(contact.phonetic_first_name).to eq('Stan')
        expect(contact.phonetic_last_name).to eq('Karver')
        expect(contact.phonetic_company).to eq('Akme')
        expect(contact.pronouns).to eq('he/him')
        expect(contact.ringtone).to eq('Marimba')
        expect(contact.texttone).to eq('Ding')

        # Relational fields
        expect(contact.emails).to eq([{ address: 'stan@example.com', label: 'Work' }])
        expect(contact.phones).to eq([{ number: '555-1234', label: 'Mobile' }])
        expect(contact.urls).to eq([{ url: 'https://stancarver.com', label: 'homepage' }])
        expect(contact.notes).to eq(['Met at RubyConf'])
        expect(contact.related_names).to eq([{ name: 'John', label: 'brother' }])
        expect(contact.social_profiles).to eq([{ service: 'Twitter', username: '@scarver2' }])
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
