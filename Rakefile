# frozen_string_literal: true

require 'rake/testtask'

task :default do
  puts `rake -T`
end

desc 'Run unit and integration tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.warning = false
end

# NOTE: run `rake run:test` in another process
desc 'Run acceptance tests'
Rake::TestTask.new(:spec_accept) do |t|
  t.pattern = 'spec/tests_acceptance/*.rb'
  t.warning = false
end

desc 'Keep rerunning unit/integration tests upon changes'
task :respec do
  sh "rerun -c 'rake spec' --ignore 'coverage/*'"
end

desc 'Keep restarting web app upon changes'
task :rerack do
  sh "rerun -c 'rackup -p 9090' --ignore 'coverage/*'"
end

namespace :run do
  desc 'Run API in dev mode'
  task :dev do
    sh 'rerun -c "rackup -p 9090"'
  end

  desc 'Run API in test mode'
  task :test do
    sh 'RACK_ENV=test rackup -p 9090'
  end
end

namespace :db do
  task :config do
    require 'sequel'
    require_relative 'config/environment' # load config info
    # require_relative 'spec/helpers/database_helper'

    def app
      GetComment::App
    end
  end

  desc 'Run migrations'
  task migrate: :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.DB, 'app/infrastructure/database/migrations')
  end

  desc 'Wipe records from all tables'
  task wipe: :config do
    DatabaseHelper.setup_database_cleaner
    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file'
  task drop: :config do
    if app.environment == :production
      puts 'Cannot remove production database!'
      return
    end

    FileUtils.rm(GetComment::App.config.DB_FILENAME)
    puts "Deleted #{GetComment::App.config.DB_FILENAME}"
  end
end

namespace :cache do
  task :config do
    require_relative 'config/environment' # load config info
    require_relative 'app/infrastructure/cache/init' # load cache client
    @api = GetComment::App
  end

  desc 'Directory listing of local dev cache'
  namespace :list do
    task :dev do
      puts 'Lists development cache'
      list = `ls _cache`
      puts 'No local cache found' if list.empty?
      puts list
    end

    desc 'Lists production cache'
    task production: :config do
      puts 'Finding production cache'
      keys = GetComment::Cache::Client.new(@api.config).keys
      puts 'No keys found' if keys.none?
      keys.each { |key| puts "Key: #{key}" }
    end
  end

  namespace :wipe do
    desc 'Delete development cache'
    task :dev do
      puts 'Deleting development cache'
      sh 'rm -rf _cache/*'
    end

    desc 'Delete production cache'
    task production: :config do
      print 'Are you sure you wish to wipe the production cache? (y/n) '
      if $stdin.gets.chomp.casecmp('y')
        puts 'Deleting production cache'
        wiped = GetComment::Cache::Client.new(@api.config).wipe
        wiped.each_key { |key| puts "Wiped: #{key}" }
      end
    end
  end
end

desc 'Run application console (irb)'
task :console do
  sh 'irb -r ./init.rb'
end

desc 'Run sequel console (irb)'
task :sequel do
  sh 'sequel sqlite://app/infrastructure/database/local/dev.db'
end

desc 'Rerun server after editting'
task :rerun do
  sh "rerun 'rackup -p 9090'"
end

namespace :vcr do
  desc 'delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

namespace :quality do
  CODE = 'app/'.freeze

  desc 'run all quality checks'
  task all: %i(rubocop reek flog)

  task :rubocop do
    sh 'rubocop'
  end

  task :reek do
    sh 'reek'
  end

  task :flog do
    sh "flog #{CODE}"
  end
end
