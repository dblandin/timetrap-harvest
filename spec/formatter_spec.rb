require_relative '../lib/timetrap_harvest/formatter'
require_relative '../lib/timetrap_harvest/config'
require 'ostruct'

describe 'HarvestFormatter' do
  def fake_entry(options = {})
    OpenStruct.new(options.merge(id: 50, sheet: 'test'))
  end

  describe '#format' do
    let(:config) do
      TimetrapHarvest::Config.new({
        'harvest' => {
          'aliases' => { 'design' => '1234 4321' },
          'round_in_minutes' => 15
        }
      })
    end

    it 'formats entries for the harvest api' do
      start = Time.local(2014, 06, 17)

      entry = fake_entry(
        note:  'working on stuff @design',
        start: start,
        end:   start + 60 * 60
      )

      formatter = TimetrapHarvest::Formatter.new(entry, config)

      expect(formatter.format).to include({
        notes: entry[:note],
        hours: 1,
        project_id: 1234,
        task_id: 4321,
        spent_date: '2014-06-17',
        external_reference: { id: 'timetrap-test-50', permalink: 'http://timetrap.local' }
      })
    end

    it 'rounds up to the configured amount' do
      start = Time.local(2014, 06, 17)

      entry = fake_entry(
        note:  'working on stuff @design',
        start: start,
        end:   start + 10 * 60
      )

      formatter = TimetrapHarvest::Formatter.new(entry, config)

      expect(formatter.format).to include({
        notes: entry[:note],
        hours: 0.25,
        project_id: 1234,
        task_id: 4321,
        spent_date: '2014-06-17',
        external_reference: { id: 'timetrap-test-50', permalink: 'http://timetrap.local' }
      })
    end
  end

  describe "#format with timetrap's duration computation" do
    let(:config) do
      TimetrapHarvest::Config.new({
        'harvest' => {
          'aliases' => { 'design' => '1234 4321' },
          'use_timetrap_rounding' => true
        }
      })
    end

    it 'formats entries for the harvest api' do
      start = Time.local(2014, 06, 17)

      entry = fake_entry(
        note:     'working on stuff @design',
        start:    start,
        end:      start + 60 * 60,
        duration: 7200 # timetrap's computation
      )

      formatter = TimetrapHarvest::Formatter.new(entry, config)

      expect(formatter.format).to include({
        notes: entry[:note],
        hours: 2,
        project_id: 1234,
        task_id: 4321,
        spent_date: '2014-06-17',
        external_reference: { id: 'timetrap-test-50', permalink: 'http://timetrap.local' }
      })
    end
  end
end
