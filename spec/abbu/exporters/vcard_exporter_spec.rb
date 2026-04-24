# spec/abbu/exporters/vcard_exporter_spec.rb
# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Abbu::Exporters::VcardExporter do
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
    it 'writes a vCard file' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'out.vcf')
        exporter.to_file(path)
        content = File.read(path)
        expect(content).to include('BEGIN:VCARD')
        expect(content).to include('FN:Stan Carver')
        expect(content).to include('EMAIL:stan@example.com')
        expect(content).to include('TEL:555-1234')
        expect(content).to include('ORG:Acme')
        expect(content).to include('END:VCARD')
      end
    end
  end

  describe '#to_stdout' do
    it 'prints vCard to stdout' do
      expect { exporter.to_stdout }.to output(/BEGIN:VCARD/).to_stdout
    end
  end

  context 'when contact has no company' do
    it 'omits the ORG line' do
      c = Abbu::Contact.new
      c.first_name = 'Prince'
      exp = described_class.new([c])
      expect { exp.to_stdout }.not_to output(/ORG:/).to_stdout
    end
  end
end
