# encoding: utf-8

module Backup
  module Syncer
    module Cloud
      class S3 < Base

        ##
        # Amazon Simple Storage Service (S3) Credentials
        attr_accessor :access_key_id, :secret_access_key

        ##
        # The S3 bucket to store files to
        attr_accessor :bucket

        ##
        # The AWS region of the specified S3 bucket
        attr_accessor :region

        # sync files only from specified date
        attr_accessor :date_from

        # archive files before uploading
        attr_accessor :archived

        ##
        # Instantiates a new Cloud::S3 Syncer.
        #
        # Pre-configured defaults specified in
        # Configuration::Syncer::Cloud::S3
        # are set via a super() call to Cloud::Base,
        # which in turn will invoke Syncer::Base.
        #
        # Once pre-configured defaults and Cloud specific defaults are set,
        # the block from the user's configuration file is evaluated.
        def initialize(&block)
          super

          instance_eval(&block) if block_given?
          @path = path.sub(/^\//, '')
          @date_from = date_from
          @archived = archived || false
          p Backup::Config.name
        end

        private

        ##
        # Established and creates a new Fog storage object for S3.
        def connection
          @connection ||= Fog::Storage.new(
            :provider              => provider,
            :aws_access_key_id     => access_key_id,
            :aws_secret_access_key => secret_access_key,
            :region                => region
          )
        end

        ##
        # Creates a new @repository_object (bucket).
        # Fetches it from S3 if it already exists,
        # otherwise it will create it first and fetch use that instead.
        def repository_object
          @repository_object ||= connection.directories.get(bucket) ||
            connection.directories.create(:key => bucket, :location => region)
        end

        ##
        # This is the provider that Fog uses for the Cloud Files
        def provider
          "AWS"
        end

        def date_from
          @date_from
        end

        def archived
          @archived
        end

      end # Class S3 < Base
    end # module Cloud
  end
end
