# lib/abbu/parsers/plist_parser.rb
# frozen_string_literal: true

module Abbu
  module Parsers
    class PlistParser
      def initialize(path)
        @path = path
      end

      def contacts
        warn 'Plist parsing not yet implemented — no .abcddb found in this archive.'
        []
      end
    end
  end
end
