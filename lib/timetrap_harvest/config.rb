class TimetrapHarvest::Config
  MissingHarvestConfig     = Class.new(StandardError)
  MissingHarvestAliases    = Class.new(StandardError)
  MissingHarvestSubdomain  = Class.new(StandardError)
  DEFAULT_ROUND_IN_MINUTES = 15

  attr_reader :timetrap_config

  def initialize(timetrap_config = Timetrap::Config)
    @timetrap_config = timetrap_config
  end

  def email
    config['email']
  end

  def password
    config['password']
  end

  def subdomain
    ensure_subdomain!

    config['subdomain']
  end

  def use_timetrap_rounding
    config['use_timetrap_rounding'] || false
  end

  def round_in_minutes
    config['round_in_minutes'] || DEFAULT_ROUND_IN_MINUTES
  end

  def alias_config(code)
    config = (code.nil? && aliases.has_key?('default_task')) ?
      aliases['default_task'] :
      aliases[code]

    if config
      config = config.split(' ')

      { project_id: config.first, task_id: config.last }
    end
  end

  def aliases
    ensure_aliases!

    config['aliases']
  end

  def config
    ensure_config!

    timetrap_config['harvest']
  end

  def ensure_config!
    fail(MissingHarvestConfig, 'Missing harvest key in .timetrap.yml config file') if timetrap_config.nil? || timetrap_config['harvest'].nil?
  end

  def ensure_aliases!
    fail(MissingHarvestAliases, 'Missing aliases key in .timetrap.yml config file') if config['aliases'].nil?
  end

  def ensure_subdomain!
    fail(MissingHarvestSubdomain, 'Missing subdomain key in .timetrap.yml config file') if config['subdomain'].nil?
  end
end
