require_relative '../lib/harvest_timetrap_formatter/formatter'
require 'ostruct'

describe 'HarvestFormatter' do
  let(:config) do
    HarvestConfig.new({
      'harvest' => {
        'aliases' => { 'design' => '1234 4321' },
        'round_in_minutes' => 15
      }
    })
  end

  describe '#format' do
    it 'formats entries for the harvest api' do
      start = Time.local(2014, 06, 17)

      entry = fake_entry(
        note:  'working on stuff @design',
        start: start,
        end:   start + 60 * 60
      )

      options = { project_id: '1234', task_id: '4321' }

      formatter = HarvestFormatter.new(entry, config)

      expect(formatter.format).to include({
        notes: entry[:note],
        hours: 1,
        project_id: 1234,
        task_id: 4321,
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

      options = { project_id: '1234', task_id: '4321', round_in_minutes: 15 }

      formatter = HarvestFormatter.new(entry, config)

      expect(formatter.format).to include({
        notes: entry[:note],
        hours: 0.25,
        project_id: 1234,
        task_id: 4321,
        spent_at: '20140617'
      })
    end

    def fake_entry(options = {})
      OpenStruct.new(options)
    end
  end
end
