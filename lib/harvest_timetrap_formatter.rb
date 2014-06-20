require_relative './harvest_timetrap_formatter/config'
require_relative './harvest_timetrap_formatter/http_client'
require_relative './harvest_timetrap_formatter/formatter'

begin
  Module.const_get('Timetrap')
rescue NameError
  module Timetrap;
    module Formatters; end
    Config = { 'harvest' => { 'aliases' => {} } }
  end
end

class Timetrap::Formatters::Harvest
  HARVESTABLE_REGEX = /@(.*)/

  attr_reader :entries
  attr_writer :client, :config

  def initialize(entries)
    @entries = entries
  end

  def output
    output_messages = []

    harvest_entries do |harvestable|
      if options = config.alias_config(harvestable.code)
        options = options.merge(round_in_minutes: config.round_in_minutes)

        payload = HarvestFormatter.new(harvestable.entry, options).format
          client.post(payload)

          output_messages << success(harvestable.entry)
      else
        output_messages << missing_code(harvestable.entry)
      end
    end

    output_messages.join("\n")
  end

  private

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

  def config
    @config ||= HarvestConfig.new
  end

  def client
    @client ||= HarvestClient.new(config.email, config.password, config.subdomain)
  end

  def success(entry)
    "Submitted: #{entry[:note]}"
  end

  def missing_code(entry)
    "Failed (missing code config): #{entry[:note]}"
  end
end
