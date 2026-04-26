# spec/abbu/exporters/csv_exporter_spec.rb
# frozen_string_literal: true

require 'tmpdir'
require 'csv'

RSpec.describe Abbu::Exporters::CsvExporter do
  let(:contact) do
    c = Abbu::Contact.new
    c.first_name = 'Stan'
    c.last_name  = 'Carver'
    c.emails     = [{ address: 'stan@example.com', label: 'Work' }]
    c.phones     = [{ number: '555-1234', label: 'Work' }]
    c.company    = 'Acme'
    c.addresses  = [{ street: '123 Main', city: 'Dallas', state: 'TX', zip: '75001', country: 'USA' }]
    c.groups     = ['Friends']
    c
  end

  let(:exporter) { described_class.new([contact]) }

  describe '#to_file' do
    it 'writes a CSV file with headers and one data row' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'out.csv')
        exporter.to_file(path)
        rows = CSV.read(path)
        expect(rows.first).to eq(%w[Name Email Phone Company Address Groups])
        expect(rows[1]).to eq(['Stan Carver', 'stan@example.com', '555-1234', 'Acme', '123 Main, Dallas, TX, 75001, USA', 'Friends'])
      end
    end
  end

  describe '#to_stdout' do
    it 'prints CSV to stdout' do
      expect { exporter.to_stdout }.to output(/Stan Carver/).to_stdout
    end
  end
end
