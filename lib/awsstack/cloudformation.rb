require 'aws-sdk'

module AwsStack
  # AWS Session creation with profile
  class CloudFormation
    def initialize(options)
      @credentials = options[:credentials]
      create_cfn_client
      @operation = options[:operation].to_sym
      @stackname = options[:stackname]
      @templatefile = options[:templatefile]
      @paramfile = options[:paramfile]
      @environment = options[:environment]
      @debug = options[:debug]

      if public_methods.include?(@operation)
        public_send @operation
      else
        puts "Requested operation '#{@operation}' is not a public method."
      end
    end

    def check
      raise unless validate_template
      puts "Template '#{@templatefile}' validated! OK."
    end

    def create
      check
      @params = read_param_file
      pp create_stack
    end

    def update
      check
      @params = read_param_file
      update_stack
    end

    def delete
      delete_stack
      puts 'Delete started...'
    end

    def operation_names
      pp @cfn.operation_names
    end

    private

    def create_cfn_client
      @cfn = Aws::CloudFormation::Client.new(credentials: @credentials)
    end

    def read_file(file)
      File.open(file, 'r').read
    end

    def read_template_file
      @template = read_file @templatefile if File.file? @templatefile
    end

    def read_param_file
      param_file = if @paramfile.class == NilClass
                     "params/#{@environment}/#{File.basename @templatefile}"
                   else
                     @paramfile
                   end
      return unless File.file? param_file
      param_string = read_file param_file
      prepare_params JSON.parse(param_string)['Parameters']
    end

    def prepare_params(params)
      params.map do |key, value|
        {
          parameter_key: key,
          parameter_value: value,
          use_previous_value: false
        }
      end
    end

    def list_stacks
      @cfn.list_stacks
    end

    def validate_template
      @cfn.validate_template(
        template_body: read_template_file
      )
    end

    def create_stack
      @stack = @cfn.create_stack(
        stack_name: @stackname, # required
        template_body: @template,
        capabilities: ['CAPABILITY_IAM'],
        parameters: @params
      )
      @stack.stack_id
    rescue Aws::CloudFormation::Errors::AlreadyExistsException, Aws::CloudFormation::Errors::ValidationError => e
      puts "#{e.class} : #{e.message}"
      exit 1
    end

    def update_stack
      @stack = @cfn.update_stack(
        stack_name: @stackname, # required
        template_body: @template,
        capabilities: ['CAPABILITY_IAM'],
        parameters: @params
      )
      @stack.stack_id
    rescue Aws::CloudFormation::Errors::ValidationError => e
      puts "#{e.class} : #{e.message}"
      exit 1
    end

    def delete_stack
      @cfn.delete_stack(
        stack_name: @stackname, # required
      )
    end

    def create_change_set
      @cfn.create_change_set
    end

    def describe_change_set
      @cfn.describe_change_set
    end

    def execute_change_set
      @cfn.execute_change_set
    end

    def delete_change_set
      @cfn.delete_change_set
    end
  end
end
