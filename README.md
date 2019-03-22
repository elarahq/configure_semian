# configure_semian
A layer to help start using semian in an easy and configurable way

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'configure_semian'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install configure_semian

## Usage

Provides functionality to define parameters for Semian. Additionality, provides read timeout to all HTTP calls.
Semian parameters can be customized for each host the http call is made to, while the timeouts can be configured at path level also.

Configuring Gem:

Define a module in config/initializers and there define the configurations for the gem as follows:

	ConfigureSemian::SemianConfiguration.configure_client{ |ob|
		ob.app_server = (true if bulkheading to be enabled by default false otherwise)
		ob.service_configs = (hash defining the default alongwith various host and path based configurations for the service)
		ob.free_hosts = (array of hosts to be free from semian)
		ob.track_exceptions = (array of exception classes to be tracked by semian)
		ob.service_name = (name of the service using this gem, this name is prepended to the name of the host to which the http call is being made to create semian resource name)
	}

Service Configs
	The complete set of parameters that can be defined in service configs alongwith their default values are

		quota: 0.75,
        success_threshold: 2,
        error_threshold: 3,
        error_timeout: 10,
        timeout: 10,
        bulkhead: true if app_server is true, false otherwise

The service configs hash provided during configuration can edit as many of these parameters as required. For the parameters for which no definition is provided during configuration takes the gem default value as defined above.
		The structure of the configs hash should be as below:

			{
				default:{gem parameters to be overridden for this whole service provided as parameters-values hash},
				hostname1: {default: {the resulting service parameters to be overridden for this host provided as parameters-values hash},
							path1: hash with timeout as key and its value to override its hosts default read timeout value for this path}
			}
Example Definition:
			 Suppose during configuration service provides app_server as true and service configs as:

				{
					default: {quota: 0.5, timeout: 16},
					'host.example.com': {
						default: {timeout: 10, bulkhead: false},
						'/example/index': {timeout: 20}
					}
				}

Then, in this example parameters values in default for the service would be

				{quota: 0.5, success_threshold: 2,error_threshold: 3,error_timeout: 10,timeout: 16, bulkhead: true},
while for 'host.example.com' would be

				{quota: 0.5, success_threshold: 2,error_threshold: 3,error_timeout: 10,timeout: 10, bulkhead: false}
and for the path '/example/index', the read timeout will be 20s.

Note: Only read timeout can be configures at path level, all the other parameters are same as that of its host's.
A suggested way to define the service_configs hash would be to define a yml file, and load that file while configuring.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/configure_semian.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
