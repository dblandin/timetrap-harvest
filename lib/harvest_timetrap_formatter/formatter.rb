require_relative './config'

class HarvestFormatter
  DEFAULT_ROUND_IN_MINUTES = 15

  attr_reader :entry, :project_id, :task_id, :round_in_minutes

  def initialize(entry, options = {})
    @entry            = entry
    @project_id       = options[:project_id]
    @task_id          = options[:task_id]
    @round_in_minutes = options.fetch(:round_in_minutes, DEFAULT_ROUND_IN_MINUTES)
  end

  def format
    { notes:      entry[:note],
      hours:      hours_for_time(entry[:start], entry[:end]),
      project_id: project_id.to_i,
      task_id:    task_id.to_i,
      spent_at:   entry[:start].strftime('%Y%m%d')
    }
  end

  def hours_for_time(start_time, end_time)
    minutes = (end_time - start_time) / 60
    rounded = round(minutes)
    hours   = (rounded / 60)
  end

  def round(minutes, nearest = round_in_minutes)
    (minutes % nearest).zero? ? minutes : (minutes + nearest) - (minutes % nearest)
  end
end
