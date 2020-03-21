# Spandx

A ruby API for interacting with the https://spdx.org software license catalogue.
This gem includes a command line interface to scan a software project for the
software licenses that are associated with each dependency in the project.
`spandx` leverages an offline cache of software licenses for known dependencies.
The offline cache allows spandx to perform a truly airgap friendly scan of software
projects.

![badge](https://github.com/mokhan/spandx/workflows/ci/badge.svg)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'spandx'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spandx

## Usage

### Command line interface

The command line interface supports operations to build and fetch the latest offline index.
See the help for each subcommand for more information on how to use the command.

```bash
モ spandx
Commands:
  spandx help [COMMAND]      # Describe available commands or one specific command
  spandx index [SUBCOMMAND]  # Manage the index
  spandx scan LOCKFILE       # Scan a lockfile and list dependencies/licenses
  spandx version             # spandx version
```

To scan a specific project file use the `scan` command:

```bash
モ spandx scan dotnet/application.sln
モ spandx scan java/pom.xml
モ spandx scan python/Pipfile.lock
モ spandx scan ruby/Gemfile.lock
```

To activate airgap mode use the `--airgap` option:

```bash
モ spandx scan dotnet/application.sln --airgap
モ spandx scan ruby/Gemfile.lock --airgap
```

Airgap mode assumes that an offline cache has been placed in `$HOME/.local/share/`.

To fetch the latest offline cache:

```bash
モ spandx index update
```

### Ruby API

To fetch the latest version of the catalogue data from [SPDX](https://spdx.org/licenses/licenses.json).

```ruby
catalogue = Spandx::Spdx::Catalogue.latest
catalogue.each do |license|
  puts license.inspect
end
```

To load an offline copy of the data.

```ruby
path = File.join(Dir.pwd, 'licenses.json')
catalogue = Spandx::Spdx::Catalogue.from_file(path)
catalogue.each do |license|
  puts license.inspect
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/cibuild` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mokhan/spandx.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
