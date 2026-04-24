# spec/abbu/archive_spec.rb
# frozen_string_literal: true

RSpec.describe Abbu::Archive do
  let(:fixture_path) { File.join(__dir__, '..', 'fixtures', 'sample.abbu') }

  describe '.new' do
    it 'raises ArgumentError for a missing path' do
      expect { described_class.new('/nonexistent/path.abbu') }
        .to raise_error(ArgumentError, /ABBU path not found/)
    end

    it 'raises ArgumentError for a non-directory path' do
      Dir.mktmpdir do |dir|
        file_path = File.join(dir, 'notabundle.abbu')
        File.write(file_path, '')
        expect { described_class.new(file_path) }
          .to raise_error(ArgumentError, /Not a directory bundle/)
      end
    end
  end

  describe '#sqlite?' do
    it 'returns true when an .abcddb file exists in the bundle' do
      Dir.mktmpdir('sample.abbu') do |dir|
        File.write(File.join(dir, 'AddressBook-v22.abcddb'), '')
        archive = described_class.new(dir)
        expect(archive.sqlite?).to be true
      end
    end

    it 'returns false when no .abcddb file exists' do
      Dir.mktmpdir('sample.abbu') do |dir|
        archive = described_class.new(dir)
        expect(archive.sqlite?).to be false
      end
    end
  end

  describe '#contacts' do
    it 'delegates to PlistParser for a plist-only bundle' do
      Dir.mktmpdir('sample.abbu') do |dir|
        archive = described_class.new(dir)
        expect(archive.contacts).to eq([])
      end
    end

    it 'delegates to SqliteParser when an .abcddb file exists' do
      Dir.mktmpdir('sample.abbu') do |dir|
        db_path = File.join(dir, 'AddressBook-v22.abcddb')
        require 'sqlite3'
        db = SQLite3::Database.new(db_path)
        db.execute('CREATE TABLE ZABCDRECORD ' \
                   '(Z_PK INTEGER PRIMARY KEY, ZFIRSTNAME TEXT, ZLASTNAME TEXT, ZORGANIZATION TEXT)')
        db.execute('CREATE TABLE ZABCDEMAILADDRESS ' \
                   '(Z_PK INTEGER PRIMARY KEY, ZOWNER INTEGER, ZADDRESSNORMALIZED TEXT)')
        db.execute('CREATE TABLE ZABCDPHONENUMBER ' \
                   '(Z_PK INTEGER PRIMARY KEY, ZOWNER INTEGER, ZFULLNUMBER TEXT)')
        db.close

        archive = described_class.new(dir)
        expect(archive.contacts).to eq([])
      end
    end
  end
end
