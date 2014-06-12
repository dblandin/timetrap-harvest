module Timetrap;
  module Formatters; end
end

class HarvestClient
end

class Timetrap::Formatters::Harvest
  attr_reader :entries
  attr_writer :client, :timetrap_config

  def initialize(entries)
    @entries = entries
  end

  def client
    @client ||= HarvestClient.new
  end

  def output
    entries.each do |entry|
      if match = /@(.*)/.match(entry[:note])
        code = match[1]
        if info = harvest_task_info(code)
          project_id, task_id = info.split(' ')

          client.submit(entry, project_id, task_id)
        end
      end
    end

    entries.map { |entry| entry[:note] }.join("\n")
  end

  private

  def harvest_task_info(code)
    harvest_aliases[code]
  end

  def harvest_aliases
    @harvest_aliases ||= timetrap_config['harvest_aliases']
  end

  def timetrap_config
    @timetrap_config ||= Timetrap::Config
  end
end
