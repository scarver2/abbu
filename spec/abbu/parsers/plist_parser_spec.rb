# spec/abbu/parsers/plist_parser_spec.rb
# frozen_string_literal: true

RSpec.describe Abbu::Parsers::PlistParser do
  describe '#contacts' do
    it 'returns an empty array and emits a warning' do
      parser = described_class.new('/some/Records')
      expect { expect(parser.contacts).to eq([]) }.to output(/Plist parsing not yet implemented/).to_stderr
    end
  end
end
