# frozen_string_literal: true

require 'roda'
require 'econfig'
require 'delegate' # This line is needed for Flash due to a bug in Rack < 2.3.0
require 'rack/cache'
require 'redis-rack-cache'

module GetComment
  # Configuration for the App
  class App < Roda
    # this plugin provides methods including environment, development?, test?, production?, configure
    plugin :environments

    # econfig checks three places for environment variables, order: ENV, secrets.yml, app.yml
    extend Econfig::Shortcut
    Econfig.env = environment.to_s
    Econfig.root = '.'

    # Used to operate on certain environments
    configure :development, :test, :app_test do
      # ENV is a Ruby built-in Class Method
      ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
    end

    configure :development do
      use Rack::Cache,
          verbose: true,
          metastore: 'file:_cache/rack/meta',
          entitystore: 'file:_cache/rack/body'
    end

    configure :production do
      # Set DATABASE_URL environment variable on production platform
      ENV['DATABASE_URL'] = 'postgres://ixihumqfnohsct:41eece053aee170f7252fbc4bd4b9a3b1235dfb4d98af9f7e5b335729d13f975@ec2-34-202-65-210.compute-1.amazonaws.com:5432/d5cuj1e65i57or'

      use Rack::Cache,
          verbose: true,
          metastore: "#{config.REDISCLOUD_URL}/0/metastore",
          entitystore: "#{config.REDISCLOUD_URL}/0/entitystore"
    end

    configure do
      require 'sequel'
      DB = Sequel.connect(ENV['DATABASE_URL']) # rubocop:disable Lint/ConstantDefinitionInBlock

      def self.DB # rubocop:disable Naming/MethodName
        DB
      end
    end
  end
end
