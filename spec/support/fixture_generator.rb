# spec/support/fixture_generator.rb
# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'sqlite3'

module FixtureGenerator
  def self.generate_abbu(path = 'spec/fixtures/TestContacts.abbu')
    FileUtils.rm_rf(path)
    FileUtils.mkdir_p("#{path}/Sources/TestAccount")

    # Create root database (Local contacts)
    db_root = SQLite3::Database.new("#{path}/AddressBook-v22.abcddb")
    setup_schema(db_root)
    seed_root(db_root)
    db_root.close

    # Create synced database (e.g., iCloud contacts in Sources)
    db_synced = SQLite3::Database.new("#{path}/Sources/TestAccount/AddressBook-v22.abcddb")
    setup_schema(db_synced)
    seed_synced(db_synced)
    db_synced.close
  end

  def self.setup_schema(db)
    db.execute <<-SQL
      CREATE TABLE ZABCDRECORD (
        Z_PK INTEGER PRIMARY KEY,
        Z_ENT INTEGER,
        ZFIRSTNAME TEXT,
        ZLASTNAME TEXT,
        ZORGANIZATION TEXT
      )
    SQL

    db.execute <<-SQL
      CREATE TABLE ZABCDEMAILADDRESS (
        Z_PK INTEGER PRIMARY KEY,
        ZOWNER INTEGER,
        ZADDRESSNORMALIZED TEXT,
        ZLABEL TEXT
      )
    SQL

    db.execute <<-SQL
      CREATE TABLE ZABCDPHONENUMBER (
        Z_PK INTEGER PRIMARY KEY,
        ZOWNER INTEGER,
        ZFULLNUMBER TEXT,
        ZLABEL TEXT
      )
    SQL

    db.execute <<-SQL
      CREATE TABLE ZABCDPOSTALADDRESS (
        Z_PK INTEGER PRIMARY KEY,
        ZOWNER INTEGER,
        ZSTREET TEXT,
        ZCITY TEXT,
        ZSTATE TEXT,
        ZZIPCODE TEXT,
        ZCOUNTRYNAME TEXT,
        ZLABEL TEXT
      )
    SQL

    db.execute <<-SQL
      CREATE TABLE Z_ABCDCONTACTGROUP (
        Z_CONTACT INTEGER,
        Z_GROUP INTEGER
      )
    SQL
  end

  def self.seed_root(db)
    # Contact 1: Basic
    db.execute("INSERT INTO ZABCDRECORD (Z_PK, Z_ENT, ZFIRSTNAME, ZLASTNAME, ZORGANIZATION) VALUES (1, 14, 'John', 'Doe', 'Acme Corp')")
    db.execute("INSERT INTO ZABCDEMAILADDRESS (ZOWNER, ZADDRESSNORMALIZED, ZLABEL) VALUES (1, 'john@example.com', 'Work')")
    db.execute("INSERT INTO ZABCDPHONENUMBER (ZOWNER, ZFULLNUMBER, ZLABEL) VALUES (1, '555-0100', 'Mobile')")
    
    # Address for Region filtering
    db.execute("INSERT INTO ZABCDPOSTALADDRESS (ZOWNER, ZSTREET, ZCITY, ZSTATE, ZCOUNTRYNAME, ZLABEL) VALUES (1, '123 Main St', 'Austin', 'TX', 'USA', 'Home')")

    # Group record
    db.execute("INSERT INTO ZABCDRECORD (Z_PK, Z_ENT, ZFIRSTNAME, ZLASTNAME, ZORGANIZATION) VALUES (2, 15, 'Colleagues', NULL, NULL)")
    db.execute("INSERT INTO Z_ABCDCONTACTGROUP (Z_CONTACT, Z_GROUP) VALUES (1, 2)")
  end

  def self.seed_synced(db)
    # Contact 3: In synced account
    db.execute("INSERT INTO ZABCDRECORD (Z_PK, Z_ENT, ZFIRSTNAME, ZLASTNAME, ZORGANIZATION) VALUES (3, 14, 'Homer', 'Simpson', 'Globex Corporation')")
    db.execute("INSERT INTO ZABCDEMAILADDRESS (ZOWNER, ZADDRESSNORMALIZED, ZLABEL) VALUES (3, 'homer@globex.com', 'Work')")
    db.execute("INSERT INTO ZABCDPHONENUMBER (ZOWNER, ZFULLNUMBER, ZLABEL) VALUES (3, '555-0200', 'Work')")
    
    # Custom contact field (We'll use a custom label for demonstration)
    db.execute("INSERT INTO ZABCDPHONENUMBER (ZOWNER, ZFULLNUMBER, ZLABEL) VALUES (3, '555-0201', 'Direct Line')")

    # Texas Region Contact
    db.execute("INSERT INTO ZABCDRECORD (Z_PK, Z_ENT, ZFIRSTNAME, ZLASTNAME, ZORGANIZATION) VALUES (4, 14, 'Collin', 'McKinney', 'Collin County')")
    db.execute("INSERT INTO ZABCDPOSTALADDRESS (ZOWNER, ZCITY, ZSTATE, ZCOUNTRYNAME, ZLABEL) VALUES (4, 'McKinney', 'TX', 'USA', 'Work')")
  end
end

if __FILE__ == $0
  FixtureGenerator.generate_abbu
  puts "Generated synthetic .abbu fixture at spec/fixtures/TestContacts.abbu"
end
