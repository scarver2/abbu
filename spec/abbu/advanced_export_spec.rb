# spec/abbu/advanced_export_spec.rb
# frozen_string_literal: true

require 'abbu'

RSpec.describe 'Advanced Exporting (TDD Scaffold)' do # rubocop:disable RSpec/DescribeClass
  let(:archive) { Abbu.open('spec/fixtures/TestContacts.abbu') }
  let(:contacts) { archive.contacts }

  context 'when filtering by region (Address Data)' do
    it 'can filter contacts by City' do
      mckinney_contacts = contacts.select { |c| c.addresses.any? { |a| a[:city] == 'McKinney' } }
      expect(mckinney_contacts.count).to eq(1)
      expect(mckinney_contacts.first.full_name).to eq('Collin McKinney')
    end

    it 'can filter contacts by State' do
      tx_contacts = contacts.select { |c| c.addresses.any? { |a| a[:state] == 'TX' } }
      expect(tx_contacts.count).to eq(2)
      expect(tx_contacts.map(&:full_name)).to contain_exactly(
        'Honorable Stan "Stretch" Carver II', 'Collin McKinney'
      )
    end
  end

  context 'with user-defined contact fields (Labels)' do
    it 'captures custom labels for phone numbers' do
      homer = contacts.find { |c| c.first_name == 'Homer' }

      direct_lines = homer.phones.select { |p| p[:label] == 'Direct Line' }
      expect(direct_lines).not_to be_empty
      expect(direct_lines.first[:number]).to eq('555-0201')
    end
  end

  context 'with user-defined groupings (Categories)' do
    it 'ignores Group entities when fetching regular contacts' do
      expect(contacts.any? { |c| c.first_name == 'Colleagues' }).to be false
    end

    it 'can expose which groups a contact belongs to' do
      stan = contacts.find { |c| c.first_name == 'Stan' }
      expect(stan.groups).to include('Colleagues')
    end
  end

  context 'when exporting' do
    it 'exports addresses to CSV correctly' do
      exporter = Abbu::Exporters::CsvExporter.new(contacts)
      csv_string = CSV.generate do |csv|
        csv << exporter.send(:headers)
        contacts.each do |c|
          csv << exporter.send(:row, c)
        end
      end
      expect(csv_string).to include('McKinney, TX, USA')
    end
  end
end
