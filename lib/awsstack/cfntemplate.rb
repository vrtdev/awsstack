require 'aws-sdk'

module AwsStack
  # AWS CFN template file handling
  class CfnTemplate
    attr_reader :body, :url
    def initialize(options)
      @credentials = options[:credentials]
      @templatefile = options[:templatefile]
      @stackname = options[:stackname]
      @bucket_name = 'awsstack.cloudformation.templates'
      @bucket_template_filename = "#{@stackname}_#{File.basename(@templatefile)}"
      template
    end

    def delete_template
      s3.delete_object(
        bucket: @bucket_name,
        key: @bucket_template_filename
      )
    end

    private

    def template
      case File.size? @templatefile
      when nil, 0
        raise "Template file : '#{@templatefile}', not found or zero length."
      when 1..51_200
        @body = template_file_body
      when 51_201..460_800
        @url = template_url
      else
        raise "Template file : '#{@templatefile}', Too large. (> 460.800 bytes)"
      end
    end

    def template_file_body
      File.open(@templatefile, 'r').read
    end

    def template_url
      create_bucket unless bucket_exist?
      put_template
      "https://s3.amazonaws.com/#{@bucket_name}/#{@bucket_template_filename}"
    end

    def put_template
      s3.put_object(
        bucket: @bucket_name,
        key: @bucket_template_filename,
        body: template_file_body
      )
    end

    def create_bucket
      s3.create_bucket(
        bucket: @bucket_name
      )
    end

    def bucket_exist?
      s3.head_bucket(
        bucket: @bucket_name
      )
      true
    rescue Aws::S3::Errors::NotFound # , Aws::S3::Errors::Http301Error
      false
    end

    def s3
      @s3 || @s3 = Aws::S3::Client.new(credentials: @credentials)
    end
  end
end
