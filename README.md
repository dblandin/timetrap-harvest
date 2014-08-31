# timetrap-harvest

A Harvest formatter for Timetrap

`timetrap-harvest` bridges the gap between your entries in Timetrap and your
project tasks in Harvest, allowing for incredibly easy timesheet submissions.

[![Gem Version](https://badge.fury.io/rb/timetrap-harvest.svg)](http://badge.fury.io/rb/timetrap-harvest)
[![Code Climate](https://codeclimate.com/github/dblandin/timetrap-harvest.png)](https://codeclimate.com/github/dblandin/timetrap-harvest)
[![Build Status](https://travis-ci.org/dblandin/timetrap-harvest.png?branch=master)](https://travis-ci.org/dblandin/timetrap-harvest)

__timetrap-harvest__'s initial development was sponsored by [dscout](https://dscout.com). Many thanks to them!

## Usage

```bash
# Reference one of your harvest project task aliases within an entry's note:
$ timetrap in working on timetrap-harvest @code
$ timetrap out

# display the entries you wish to submit using the harvest formatter:
$ timetrap display --start 'last monday' --end 'last friday' --format harvest
```

## Installation

```bash
$ gem install timetrap-harvest

$ echo "require 'timetrap-harvest'" > ./path/to/formatters/harvest.rb
```

## Configuration

```yaml
# ~/.timetrap.yml
---
...
harvest:
  email:     'email@example.com'
  password:  'password'
  subdomain: 'company'
  round_in_minutes: 30 # defaults to 15
  aliases:
    code:   '[project id] [task id]'
    design: '[project id] [task id]'
    misc:   '[project id] [task id]'
```

## Dependencies

timetrap-harvest depends upon the timetrap gem

When installing timetrap-harvest, timetrap is installed for you as a runtime
dependency.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Thanks

* [Parker Selbert](https://github.com/sorentwo) for reviewing the initial commits
* [dscout](https://dscout.com) - for their sponsorship
