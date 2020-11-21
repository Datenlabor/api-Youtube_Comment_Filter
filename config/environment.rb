# frozen_string_literal: true

require 'roda'
require 'econfig'

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
    configure :development, :test do
      # ENV is a Ruby built-in Class Method
      ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
    end

    configure :production do
      # Set DATABASE_URL environment variable on production platform
      ENV['DATABASE_URL'] = 'postgres://cknzqgnfemetnw:d7c07c64d424a807e5b2852ca573888d9a52fcb463a35567f87600d114cd246c@ec2-34-200-106-49.compute-1.amazonaws.com:5432/d72iigjoaft4m8'
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
