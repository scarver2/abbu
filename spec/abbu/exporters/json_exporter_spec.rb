# spec/abbu/exporters/json_exporter_spec.rb
# frozen_string_literal: true

require 'tmpdir'
require 'json'

RSpec.describe Abbu::Exporters::JsonExporter do
  let(:contact) do
    c = Abbu::Contact.new
    c.first_name = 'Stan'
    c.last_name  = 'Carver'
    c.emails     = [{ address: 'stan@example.com', label: 'Work' }]
    c.phones     = [{ number: '555-1234', label: 'Mobile' }]
    c.company    = 'Acme'
    c.job_title  = 'Engineer'
    c.addresses  = [{ street: '123 Main', city: 'Dallas', state: 'TX', zip: '75001', country: 'USA' }]
    c.urls       = [{ url: 'https://stancarver.com', label: 'homepage' }]
    c.notes      = ['Great guy']
    c.related_names   = [{ name: 'John', label: 'brother' }]
    c.social_profiles = [{ service: 'Twitter', username: '@scarver2' }]
    c
  end

  let(:exporter) { described_class.new([contact]) }

  describe '#to_file' do
    it 'writes a JSON file with all contact fields' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'out.json')
        exporter.to_file(path)
        data = JSON.parse(File.read(path)).first

        expect(data['name']).to eq('Stan Carver')
        expect(data['first_name']).to eq('Stan')
        expect(data['company']).to eq('Acme')
        expect(data['job_title']).to eq('Engineer')
        expect(data['emails'].first['address']).to eq('stan@example.com')
        expect(data['phones'].first['number']).to eq('555-1234')
        expect(data['addresses'].first['city']).to eq('Dallas')
        expect(data['urls'].first['url']).to eq('https://stancarver.com')
        expect(data['notes']).to eq(['Great guy'])
        expect(data['related_names'].first['name']).to eq('John')
        expect(data['social_profiles'].first['username']).to eq('@scarver2')
      end
    end
  end

  describe '#to_stdout' do
    it 'prints JSON to stdout' do
      expect { exporter.to_stdout }.to output(/Stan Carver/).to_stdout
    end
  end
end
