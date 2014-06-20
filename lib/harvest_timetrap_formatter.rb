require_relative './harvest_timetrap_formatter/config'
require_relative './harvest_timetrap_formatter/http_client'
require_relative './harvest_timetrap_formatter/formatter'
require_relative './harvest_timetrap_formatter/harvester'
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
  attr_reader :entries
  attr_writer :client, :config

  def initialize(entries)
    @entries = entries
  end

  def output
    results = entries.map { |entry| HarvestFormatter.new(entry, config).format }

    harvester = Harvester.new(results, client)
    results   = harvester.harvest

    HarvestOutput.new(results).generate
  end

  private

  def config
    @config ||= HarvestConfig.new
  end

  def client
    @client ||= HarvestClient.new(config.email, config.password, config.subdomain)
  end
end
