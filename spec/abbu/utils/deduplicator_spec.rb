# spec/abbu/utils/deduplicator_spec.rb
# frozen_string_literal: true

RSpec.describe Abbu::Utils::Deduplicator do
  def build_contact(first_name, email)
    c = Abbu::Contact.new
    c.first_name = first_name
    c.emails = [email]
    c
  end

  let(:c1) { build_contact('Stan',  'stan@example.com') }
  let(:c2) { build_contact('Stan2', 'stan@example.com') }
  let(:c3) { build_contact('Other', 'other@example.com') }

  describe '#duplicates' do
    it 'finds contacts sharing the same email' do
      dupes = described_class.new([c1, c2, c3]).duplicates
      expect(dupes['stan@example.com'].size).to eq(2)
    end

    it 'excludes contacts without email' do
      no_email = Abbu::Contact.new
      dupes = described_class.new([no_email, c3]).duplicates
      expect(dupes).to be_empty
    end

    it 'returns empty hash when no duplicates exist' do
      dupes = described_class.new([c1, c3]).duplicates
      expect(dupes).to be_empty
    end
  end
end
