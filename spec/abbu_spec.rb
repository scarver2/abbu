# spec/abbu_spec.rb
# frozen_string_literal: true

RSpec.describe Abbu do
  it 'has a version number' do
    expect(Abbu::VERSION).not_to be_nil
  end

  it 'responds to .open' do
    expect(described_class).to respond_to(:open)
  end

  describe '.open' do
    it 'returns an Archive for a valid bundle path' do
      Dir.mktmpdir('sample.abbu') do |dir|
        archive = described_class.open(dir)
        expect(archive).to be_a(Abbu::Archive)
      end
    end
  end
end
