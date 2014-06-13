require 'net/http'
require 'json'

module Timetrap;
  module Formatters; end
end

class HarvestClient
  attr_reader :email, :password

  def initialize(email, password)
    @email    = email
    @password = password
  end

  def submit(entry, project_id, task_id)
    req = Net::HTTP::Post.new(uri)
    req.basic_auth(username, password)
    req.body            = payload(entry, project_id, task_id).to_json
    req['Content-Type'] = 'application/json'
    req['Accept']       = 'application/json'

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end
  end

  def payload(entry, project_id, task_id)
    { notes:      entry[:notes],
      hours:      '1',
      project_id: project_id,
      task_id:    task_id,
      spent_at:   'Fri, 13 Jun 2014'
    }
  end
end

class Timetrap::Formatters::Harvest
  HARVESTABLE_REGEX = /@(.*)/

  attr_reader :entries
  attr_writer :client, :timetrap_config

  def initialize(entries)
    @entries = entries
  end

  def client
    @client ||= HarvestClient.new(harvest_username, harvest_password)
  end

  def harvest_username
    Timetrap::Config['harvest']['username']
  end

  def harvest_password
    Timetrap::Config['harvest']['password']
  end

  def output
    harvest_entries do |entry, code|
      if info = info_for_code(code)
        client.submit(entry, info.project_id, info.task_id)
      end
    end

    entries.map { |entry| entry[:note] }.join("\n")
  end

  def harvest_entries
    entries.each do |entry|
      if match = HARVESTABLE_REGEX.match(entry[:note])
        yield entry, match[1]
      end
    end
  end

  private

  def info_for_code(code)
    if alias_config = harvest_aliases[code]
      alias_config = alias_config.split(' ')

      OpenStruct.new(project_id: alias_config[0], task_id: alias_config[1])
    end
  end

  def harvest_aliases
    @harvest_aliases ||= timetrap_config['harvest']['aliases']
  end

  def timetrap_config
    @timetrap_config ||= Timetrap::Config
  end
end
