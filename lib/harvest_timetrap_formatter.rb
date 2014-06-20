require_relative './harvest_timetrap_formatter/config'
require_relative './harvest_timetrap_formatter/http_client'
require_relative './harvest_timetrap_formatter/formatter'
require_relative './harvest_timetrap_formatter/output'

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
    submitted = []
    failed    = []

    harvest_entries do |harvestable|
      payload = HarvestFormatter.new(harvestable.entry, config).format

      if payload.key? :error
        failed << { error: payload[:error], note: harvestable.entry[:note] }
      else
        client.post(payload)

        submitted << { note: harvestable.entry[:note] }
      end
    end

    HarvestOutput.new(submitted: submitted, failed: failed).generate
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
