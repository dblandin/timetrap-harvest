require_relative '../lib/harvest_timetrap_formatter.rb'
require 'ostruct'

describe 'Timetrap::Formatters::Harvest' do
  describe '#output' do
    it 'it does not submit entries without an alias' do
      fake_client = double(:fake_client)

      entries = []
      entries << fake_entry(note: 'working on stuff')

      formatter = Timetrap::Formatters::Harvest.new(entries)
      formatter.client = fake_client

      expect(fake_client).to_not receive(:submit)
      expect(formatter.output).to eq('working on stuff')
    end

    it 'submit entries with an alias' do
      fake_client = double(:fake_client)

      entries = []
      entries << fake_entry(note: 'working on stuff @design')

      formatter = Timetrap::Formatters::Harvest.new(entries)
      formatter.client = fake_client

      config = { 'harvest_aliases' => { 'design' => '123456 987654' } }

      formatter.timetrap_config = config

      expect(fake_client).to receive(:submit)
      expect(formatter.output).to eq('working on stuff @design')
    end
  end

  def fake_entry(options = {})
    OpenStruct.new(options)
  end
end
