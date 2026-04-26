# spec/abbu/exporters/vcard_exporter_spec.rb
# frozen_string_literal: true

require 'tmpdir'

RSpec.describe Abbu::Exporters::VcardExporter do
  let(:contact) do
    c = Abbu::Contact.new
    c.first_name = 'Stan'
    c.last_name  = 'Carver'
    c.nickname   = 'Stretch'
    c.emails     = [{ address: 'stan@example.com', label: 'Work' }]
    c.phones     = [{ number: '555-1234', label: 'Mobile' }]
    c.company    = 'Acme'
    c.job_title  = 'Engineer'
    c.addresses  = [{ street: '123 Main', city: 'Dallas', state: 'TX', zip: '75001', country: 'USA', label: 'Home' }]
    c.urls       = [{ url: 'https://stancarver.com', label: 'homepage' }]
    c.notes      = ['Great guy']
    c.social_profiles = [{ service: 'Twitter', username: '@scarver2' }]
    c
  end

  let(:exporter) { described_class.new([contact]) }

  describe '#to_file' do
    it 'writes a vCard file with all fields' do
      Dir.mktmpdir do |dir|
        path = File.join(dir, 'out.vcf')
        exporter.to_file(path)
        content = File.read(path)

        expect(content).to include('BEGIN:VCARD')
        expect(content).to include('FN:Stan "Stretch" Carver')
        expect(content).to include('N:Carver;Stan;;;')
        expect(content).to include('NICKNAME:Stretch')
        expect(content).to include('ORG:Acme')
        expect(content).to include('TITLE:Engineer')
        expect(content).to include('EMAIL;TYPE=Work:stan@example.com')
        expect(content).to include('TEL;TYPE=Mobile:555-1234')
        expect(content).to include('ADR;TYPE=Home:;;123 Main;Dallas;TX;75001;USA')
        expect(content).to include('URL:https://stancarver.com')
        expect(content).to include('NOTE:Great guy')
        expect(content).to include('X-SOCIALPROFILE;TYPE=Twitter:@scarver2')
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

  context 'when contact has no nickname' do
    it 'omits the NICKNAME line' do
      c = Abbu::Contact.new
      c.first_name = 'Cher'
      exp = described_class.new([c])
      expect { exp.to_stdout }.not_to output(/NICKNAME:/).to_stdout
    end
  end
end
