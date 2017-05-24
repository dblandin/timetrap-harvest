require_relative '../lib/timetrap-harvest'
require 'ostruct'

describe 'Timetrap::Formatters::Harvest' do
  describe '#output' do
    it 'submit entries with an alias' do
      fake_client = double(:fake_client)

      entry = fake_entry(
        note:  'working on stuff @design',
        start: Time.now,
        end:   Time.now
      )

      formatter = Timetrap::Formatters::Harvest.new([entry])
      formatter.client = fake_client

      config = TimetrapHarvest::Config.new({ 'harvest' => { 'aliases' => { 'design' => '123456 987654' } } })

      formatter.config = config

      expect(fake_client).to receive(:post)
      expect(formatter.output).to include('Submitted: working on stuff @design')
    end

    it 'it does not submit entries without an alias' do
      fake_client = double(:fake_client)

      entries = []
      entries << fake_entry(
        note:  'working on stuff',
        start: Time.now,
        end:   Time.now
      )

      formatter = Timetrap::Formatters::Harvest.new(entries)
      formatter.client = fake_client

      expect(fake_client).to_not receive(:post)
      expect(formatter.output).to include('Submitted: 0')
    end

    it 'will display an error message when a code config is missing' do
      fake_client = double(:fake_client)

      entry = fake_entry(
        note:  'working on stuff @unknown',
        start: Time.now,
        end:   Time.now
      )

      formatter = Timetrap::Formatters::Harvest.new([entry])
      formatter.client = fake_client

      config = TimetrapHarvest::Config.new({ 'harvest' => { 'aliases' => {} } })
      formatter.config = config

      expect(fake_client).to_not receive(:post)
      expect(formatter.output).to include(
        "Failed (Missing task alias config): working on stuff @unknown"
      )
    end

    it 'will display an error message when an entry is running' do
      fake_client = double(:fake_client)

      entry = fake_entry(
        note:  'working on stuff @unknown',
        start: Time.now,
        end:   nil
      )

      formatter = Timetrap::Formatters::Harvest.new([entry])
      formatter.client = fake_client

      config = TimetrapHarvest::Config.new({ 'harvest' => { 'aliases' => {} } })
      formatter.config = config

      expect(fake_client).to_not receive(:post)
      expect(formatter.output).to include(
        "Failed (Entry not ended yet): working on stuff @unknown"
      )
    end
  end

  def fake_entry(options = {})
    OpenStruct.new(options)
  end
end
