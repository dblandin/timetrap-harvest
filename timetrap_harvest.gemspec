# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'timetrap_harvest/version'

Gem::Specification.new do |s|
  s.name        = 'timetrap-harvest'
  s.version     = TimetrapHarvest::VERSION
  s.date        = '2014-06-12'
  s.summary     = 'A Harvest formatter for Timetrap'
  s.description = <<-DESCRIPTION
    timetrap-harvest bridges the gap between your entries in Timetrap and your
    project tasks in Harvest allowing for incredible easy timesheet
    submissions.
  DESCRIPTION
  s.authors     = ['Devon Blandin']
  s.email       = 'dblandin@gmail.com'
  s.files       = Dir.glob('lib/**/*.rb')
  s.homepage    = 'https://github.com/dblandin/timetrap-harvest'
  s.license     = 'MIT'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry'
end
