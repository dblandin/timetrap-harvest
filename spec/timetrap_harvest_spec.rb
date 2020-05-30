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

      expect(fake_client).to receive(:fetch)
      expect(fake_client).to receive(:create_or_update)
      expect(formatter.output).to include('Submitted: working on stuff @design')
    end

    context 'with or without alias' do
      let(:fake_client) { double(:fake_client) }
      let (:date) { Time.new(2002, 10, 31, 2, 2, 2, '+00:00') }
      let(:entries) { [fake_entry(note: 'stuff', start: date, end: date)] }
      let(:formatter) { Timetrap::Formatters::Harvest.new(entries) }

      before(:each) do
        formatter.client = fake_client
      end

      it 'it does not submit entries without an alias' do
        expect(fake_client).to_not receive(:post)
        expect(formatter.output).to include('Submitted: 0')
      end

      it 'submits entries missing an alias if default_task alias was defined' do
        formatter.config = TimetrapHarvest::Config.new({
          'harvest' => {
            'aliases' => {
              'default_task' => '1234 9876',
            }
          }
        })


        expect(fake_client).to receive(:fetch)
        expect(fake_client).to receive(:create_or_update)
        expect(formatter.output).to include('Submitted: 1')
      end
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

      config = TimetrapHarvest::Config.new({ 'harvest' => { 'aliases' => { 'default_task' => '1234 9876' } } })
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
