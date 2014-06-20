require_relative '../lib/harvest_timetrap_formatter.rb'
require 'ostruct'

describe 'Timetrap::Formatters::Harvest' do
  describe '#format' do
    it 'formats entries for the harvest api' do
      start = Time.local(2014, 06, 17)

      entry = fake_entry(
        note:  'working on stuff @design',
        start: start,
        end:   start + 60 * 60
      )

      formatter = Timetrap::Formatters::Harvest.new([entry])

      expect(formatter.format(entry, 1, 1)).to include({
        notes: entry[:note],
        hours: 1,
        project_id: 1,
        task_id: 1,
        spent_at: '20140617'
      })
    end

    it 'rounds up to the configured amount' do
      start = Time.local(2014, 06, 17)

      entry = fake_entry(
        note:  'working on stuff @design',
        start: start,
        end:   start + 10 * 60
      )

      formatter = Timetrap::Formatters::Harvest.new([entry])

      config = { 'harvest' => { 'round_in_minutes' => 15 } }

      formatter.timetrap_config = config

      expect(formatter.format(entry, 1, 1)).to include({
        notes: entry[:note],
        hours: 0.25,
        project_id: 1,
        task_id: 1,
        spent_at: '20140617'
      })
    end
  end

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

      config = { 'harvest' => { 'aliases' => { 'design' => '123456 987654' } } }

      formatter.timetrap_config = config

      expect(fake_client).to receive(:post)
      expect(formatter.output).to eq('Submitted: working on stuff @design')
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
      expect(formatter.output).to be_empty
    end
  end

  def fake_entry(options = {})
    OpenStruct.new(options)
  end
end
