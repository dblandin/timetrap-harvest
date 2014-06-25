# harvest-timetrap

timetrap-harvest bridges the gap between your entries in Timetrap and your
project tasks in Harvest allowing for incredible easy timesheet submissions.

## Usage

```
$ t[imetrap] d[isplay] --start 'last monday' --end 'last friday' -f[ormat] harvest
```

## Installation

```bash
$ gem install harvest-timetrap

$ echo require "harvest-timetrap" > ./path/to/formatters/harvest.rb
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
  aliases:
    code:   '[project id] [task id]'
    design: '[project id] [task id]'
    misc:   '[project id] [task id]'
```
