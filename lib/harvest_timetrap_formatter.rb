require 'net/http'
require 'json'
require 'uri'

begin
  Module.const_get('Timetrap')
rescue NameError
  module Timetrap;
    module Formatters; end
    Config = { 'harvest' => { } }
  end
end

class HarvestClient
  HARVEST_ADD_URI = URI('https://dscout.harvestapp.com/daily/add')

  attr_reader :email, :password

  def initialize(email, password)
    @email    = email
    @password = password
  end

  def post(payload)
    req = Net::HTTP::Post.new(HARVEST_ADD_URI.request_uri)
    req.basic_auth(email, password)
    req.body            = payload.to_json
    req['Content-Type'] = 'application/json'
    req['Accept']       = 'application/json'

    res = Net::HTTP.start(HARVEST_ADD_URI.hostname, HARVEST_ADD_URI.port, use_ssl: true) do |http|
      http.request(req)
    end
  end
end

class Timetrap::Formatters::Harvest
  HARVESTABLE_REGEX        = /@(.*)/
  DEFAULT_ROUND_IN_MINUTES = 15
  MissingHarvestConfig     = Class.new(StandardError)
  MissingHarvestAliases    = Class.new(StandardError)

  attr_reader :entries
  attr_writer :client, :config

  def initialize(entries)
    @entries = entries
  end

  def client
    @client ||= HarvestClient.new(harvest_email, harvest_password)
  end

  def harvest_email
    Timetrap::Config['harvest']['email']
  end

  def harvest_password
    Timetrap::Config['harvest']['password']
  end

  def output
    ensure_config!

    output_messages = []

    harvest_entries do |harvestable|
      if info = info_for_code(harvestable.code)
        payload = format(harvestable.entry, info.project_id, info.task_id)

        client.post(payload)

        output_messages << success(harvestable.entry)
      else
        output_messages << missing_code(harvestable.entry)
      end
    end

    output_messages.join("\n")
  end

  def ensure_config!
    raise MissingHarvestConfig 'Missing harvest key in .timetrap.yml config file' if config.nil? || !config.key?('harvest')
  end

  def ensure_aliases!
    raise MissingHarvestAliases 'Missing aliases key in .timetrap.yml config file' if config['harvest']['aliases'].nil?
  end

  def success(entry)
    "Submitted: #{entry[:note]}"
  end

  def missing_code(entry)
    "Failed (missing code config): #{entry[:note]}"
  end

  def generate_ouput(entries)
    entries.map { |entry| "Submitted: #{entry[:note]}" }.join("\n")
  end

  def harvest_entries
    entries.each do |entry|
      if entry[:start] && entry[:end]
        if match = HARVESTABLE_REGEX.match(entry[:note])
          code = match[1]

          yield OpenStruct.new(entry: entry, code: code)
        end
      end
    end
  end

  def format(entry, project_id, task_id)
    { notes:      entry[:note],
      hours:      hours_for_time(entry[:start], entry[:end]),
      project_id: project_id,
      task_id:    task_id,
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

  private

  def info_for_code(code)
    ensure_aliases!

    if alias_config = harvest_aliases[code]
      alias_config = alias_config.split(' ')

      OpenStruct.new(project_id: alias_config[0], task_id: alias_config[1])
    end
  end

  def round_in_minutes
    @round_in_seconds ||= config['harvest']['round_in_minutes'] || DEFAULT_ROUND_IN_MINUTES
  end

  def harvest_aliases
    @harvest_aliases ||= config['harvest']['aliases']
  end

  def config
    @config ||= Timetrap::Config
  end
end
