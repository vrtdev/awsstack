# Awsstack

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/awsstack`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'awsstack'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install awsstack

## Usage

    awsstack --help
        /usr/local/bin/awsstack [OPTION]

        -h, --help:
        show help

        -r, --role <rolename>
        IAM role to use. From ~/.aws/config

        -o, --operation <operation>
        Operation to perform on the template. (...)
        Operations :
          check   Check a template on AWS
          create  Create a stack
          update  Update a stack
          delete  Delete a stack

        -s, --stackname <stackname>
        Stackname to operate on.

        -t, --templatefile <file>
        Template file to use. (JSON format)

        -p, --paramfile <file>
        Optional Parameter file. (JSON format)

        -e, --environment <environment>
        Execution environment. (dev, stag, prod, ...)

        -d, --debug [level]:
        Debug level.
        
( Todo: Debug Level is not implemented )

### example use

    awsstack -r vrt-dpc-sandbox-admin -t output/aem_author.json -e dev -s Aemsecuritydev -o create

### params file

To pass parameters to the CFN with this script, create a json file with the same
name as the template file but in the directory <repo>/params/<env>/<template>
The content should look like this.

This file will automatically be used and the params passed to CFN.

    {
        "Parameters": {
            "AemEnvironmentNameParameter": "stag",
            "LabelOwner": "causbrwa"
        }
    }

You can also pass a --paramfile option specifying an alternate params file


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/awsstack.
