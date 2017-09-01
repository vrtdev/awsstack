# https://github.com/a2ikm/aws_config
require 'aws_config'
# http://docs.aws.amazon.com/AWSJavaScriptSDK/latest/top-level-namespace.html
# require 'aws-sdk-core'
require 'aws-sdk-core'
require 'yaml'
require 'io/console'

module AwsStack
  # AWS Session creation with profile
  class AwsSession
    attr_reader :assumed_role

    def initialize(options)
      @profile = options[:profile] || 'default'
      @session_save_lifetime = options[:session_save_lifetime] || 3600
      @session_save_filename = options[:session_save_filename] || "./.aws_session_#{@profile}.yaml"
      @region = options[:region] || AWSConfig[@profile].region
      @role = options[:role] || AWSConfig[@profile].role_arn
      @aws_access_key_id = options[:aws_access_key_id] || AWSConfig[@profile].aws_access_key_id
      @aws_secret_access_key = options[:aws_secret_access_key] || AWSConfig[@profile].aws_secret_access_key
      @mfa_serial = options[:mfa_serial] || AWSConfig[@profile].mfa_serial
      session_start
    end

    def session_start
      load_session
      create_session
      # Aws.config.update(credentials: @assumed_role, region: @region)
    end

    def create_session
      return if @assumed_role
      read_token_input
      assume_role
      save_session @assumed_role
      puts "Session data saved. You now hav a valid AWS profile for : #{@profile}"
    end

    def read_token_input
      print 'Enter MFA token: '
      @token_code = STDIN.noecho(&:gets) # gets.chomp
      puts ''
      @token_code.chomp!
    end

    def sts_client
      Aws::STS::Client.new(
        access_key_id: @aws_access_key_id,
        secret_access_key: @aws_secret_access_key
      )
    end

    def assume_role
      @assumed_role = sts_client.assume_role(
        duration_seconds: @session_save_lifetime,
        role_arn: @role,
        role_session_name: ENV['USER'],
        serial_number: @mfa_serial,
        token_code: @token_code
      )
    rescue Aws::STS::Errors::ValidationError, Aws::STS::Errors::AccessDenied => e
      puts "#{e.class} : #{e.message}"
      exit 1
    end

    def save_session(role)
      File.open(@session_save_filename, 'w') { |f| f.write role.to_yaml } # Store
    end

    def load_session
      return unless File.file?(@session_save_filename)
      @assumed_role = YAML.load_file(@session_save_filename) # Load
      if Time.now > @assumed_role.credentials.expiration
        puts 'Session credentials expired. Removing obsolete sessions.yaml file'
        @assumed_role = nil
        File.delete(@session_save_filename)
      else
        @assumed_role.assumed_role_user.arn
        # puts "Found valid session credentials : #{arn}"
      end
    end
  end
end
