# lib/abbu/archive.rb
# frozen_string_literal: true

require_relative 'parsers/sqlite_parser'
require_relative 'parsers/plist_parser'

module Abbu
  class Archive
    attr_reader :path

    def initialize(path)
      @path = Pathname.new(path)
      validate!
    end

    def contacts
      parser.contacts
    end

    def sqlite?
      db_paths.any?
    end

    private

    def validate!
      raise ArgumentError, "ABBU path not found: #{@path}" unless @path.exist?
      raise ArgumentError, "Not a directory bundle: #{@path}" unless @path.directory?
    end

    def db_paths
      @db_paths ||= @path.glob('**/*.abcddb')
    end

    def records_path
      @records_path ||= @path.join('Records')
    end

    def parser
      if sqlite?
        Parsers::SqliteParser.new(db_paths)
      else
        Parsers::PlistParser.new(records_path)
      end
    end
  end
end
