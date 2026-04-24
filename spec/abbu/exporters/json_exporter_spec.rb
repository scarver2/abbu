# spec/abbu/exporters/json_exporter_spec.rb
# frozen_string_literal: true

require 'tmpdir'
require 'json'

RSpec.describe Abbu::Exporters::JsonExporter do
  let(:contact) do
    c = Abbu::Contact.new
    c.first_name = 'Stan'
    c.last_name  = 'Carver'
    c.emails     = ['stan@example.com']
    c.phones     = ['555-1234']
    c.company    = 'Acme'
    c
  end

  let(:exporter) { described_class.new([contact]) }

  describe '#to_file' do
    it 'writes a JSON file with contact data' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'out.json')
        exporter.to_file(path)
        data = JSON.parse(File.read(path))
        expect(data.first['name']).to eq('Stan Carver')
        expect(data.first['emails']).to eq(['stan@example.com'])
      end
    end
  end

  describe '#to_stdout' do
    it 'prints JSON to stdout' do
      expect { exporter.to_stdout }.to output(/Stan Carver/).to_stdout
    end
  end
end
