# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'harvest_timetrap_formatter/version'

Gem::Specification.new do |s|
  s.name        = 'harvest-timetrap-formatter'
  s.version     = HarvestTimetrapFormatter::VERSION
  s.date        = '2014-06-12'
  s.summary     = 'A Harvest Timetrap Formatter'
  s.description = 'Sends Timetrap entries to Harvest timesheet'
  s.authors     = ['Devon Blandin']
  s.email       = 'dblandin@gmail.com'
  s.files       = ['lib/harvest_timetrap_formatter.rb']
  s.homepage    = 'https://github.com/dblandin/harvest-timetrap-formatter'
  s.license     = 'MIT'

  s.add_development_dependency 'rspec'
end
