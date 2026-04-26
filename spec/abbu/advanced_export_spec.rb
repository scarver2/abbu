# spec/abbu/advanced_export_spec.rb
# frozen_string_literal: true

require 'abbu'

RSpec.describe 'Advanced Exporting (TDD Scaffold)' do
  let(:archive) { Abbu.open('spec/fixtures/TestContacts.abbu') }
  let(:contacts) { archive.contacts }

  context 'Filtering by Region (Address Data)' do
    it 'can filter contacts by City' do
      # Assuming we add an address array to Contact and an easy filter method
      mckinney_contacts = contacts.select { |c| c.addresses.any? { |a| a[:city] == 'McKinney' } }
      expect(mckinney_contacts.count).to eq(1)
      expect(mckinney_contacts.first.full_name).to eq('Collin McKinney')
    end

    it 'can filter contacts by State' do
      tx_contacts = contacts.select { |c| c.addresses.any? { |a| a[:state] == 'TX' } }
      expect(tx_contacts.count).to eq(2)
      expect(tx_contacts.map(&:full_name)).to contain_exactly('Honorable Stan "Stretch" Carver II', 'Collin McKinney')
    end
  end

  context 'User-defined Contact Fields (Labels)' do
    it 'captures custom labels for phone numbers' do
      homer = contacts.find { |c| c.first_name == 'Homer' }
      
      # Expecting a structure like [{ number: "555-0201", label: "Direct Line" }]
      direct_lines = homer.phones.select { |p| p[:label] == 'Direct Line' }
      expect(direct_lines).not_to be_empty
      expect(direct_lines.first[:number]).to eq('555-0201')
    end
  end

  context 'User-defined Groupings (Categories)' do
    it 'ignores Group entities when fetching regular contacts' do
      # Currently, the parser pulls everything from ZABCDRECORD.
      # The "Colleagues" group will appear as an empty contact.
      expect(contacts.any? { |c| c.first_name == 'Colleagues' }).to be false
    end

    it 'can expose which groups a contact belongs to' do
      stan = contacts.find { |c| c.first_name == 'Stan' }
      expect(stan.groups).to include('Colleagues')
    end
  end
  
  context 'Exporting' do
    it 'exports addresses to CSV correctly' do
      exporter = Abbu::Exporters::CsvExporter.new(contacts)
      csv_string = CSV.generate { |csv| csv << exporter.send(:headers); contacts.each { |c| csv << exporter.send(:row, c) } }
      expect(csv_string).to include('McKinney, TX, USA')
    end
  end
end
