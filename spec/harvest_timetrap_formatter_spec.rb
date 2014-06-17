require_relative '../lib/harvest_timetrap_formatter.rb'
require 'ostruct'

describe 'Timetrap::Formatters::Harvest' do
  describe '#output' do
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
      expect(formatter.output).to be_empty
    end

    it 'submit entries with an alias' do
      fake_client = double(:fake_client)

      entries = []
      entries << fake_entry(
        note:  'working on stuff @design',
        start: Time.now,
        end:   Time.now
      )

      formatter = Timetrap::Formatters::Harvest.new(entries)
      formatter.client = fake_client

      config = { 'harvest' => { 'aliases' => { 'design' => '123456 987654' } } }

      formatter.timetrap_config = config

      expect(fake_client).to receive(:post)
      expect(formatter.output).to eq('Submitted: working on stuff @design')
    end

    it 'can format entries' do
      entries = []

      start = Time.local(2014, 06, 17)

      entry = fake_entry(
        note:  'working on stuff @design',
        start: start,
        end: start + 60 * 60
      )

      entries << entry

      formatter = Timetrap::Formatters::Harvest.new(entries)

      expect(formatter.format(entry, 1, 1)).to include({
        notes: entry[:note],
        hours: 1,
        project_id: 1,
        task_id: 1,
        spent_at: '20140617'
      })
    end
  end

  def fake_entry(options = {})
    OpenStruct.new(options)
  end
end
