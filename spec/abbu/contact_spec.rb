# spec/abbu/contact_spec.rb
# frozen_string_literal: true

RSpec.describe Abbu::Contact do
  subject(:contact) { described_class.new }

  it 'initializes with empty emails and phones' do
    expect(contact.emails).to eq([])
    expect(contact.phones).to eq([])
  end

  describe '#full_name' do
    it 'joins first and last name' do
      contact.first_name = 'Stan'
      contact.last_name  = 'Carver'
      expect(contact.full_name).to eq('Stan Carver')
    end

    it 'includes prefix, nickname, and suffix if present' do
      contact.first_name = 'Stan'
      contact.last_name  = 'Carver'
      contact.prefix     = 'Honorable'
      contact.nickname   = 'Stretch'
      contact.suffix     = 'II'
      expect(contact.full_name).to eq('Honorable Stan "Stretch" Carver II')
    end

    it 'handles missing last name' do
      contact.first_name = 'Prince'
      expect(contact.full_name).to eq('Prince')
    end

    it 'handles missing first name' do
      contact.last_name = 'Cher'
      expect(contact.full_name).to eq('Cher')
    end

    it 'returns empty string when both names are nil' do
      expect(contact.full_name).to eq('')
    end
  end

  describe '#to_s' do
    it 'includes class name and fields' do
      contact.first_name = 'Stan'
      expect(contact.to_s).to include('Abbu::Contact')
      expect(contact.to_s).to include('Stan')
    end
  end

  describe '#inspect' do
    it 'delegates to to_s' do
      contact.first_name = 'Stan'
      expect(contact.inspect).to eq(contact.to_s)
    end
  end
end
