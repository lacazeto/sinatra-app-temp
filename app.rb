require 'sinatra'
require 'sinatra/base'
require 'sequel'
require 'slim'
require 'yaml'
require 'digest'
require 'sinatra/reloader'
require 'date'
require 'pry'
require 'byebug'


class Todo < Sinatra::Application
  # CONFIG APP
  configure do
    set :environment, :development # ENV['RACK_ENV']
    register Sinatra::Reloader
    enable :reloader
    also_reload 'lib/*.rb'
    also_reload 'models/*.rb'
    after_reload do
      puts "Reloaded: #{Time.now}"
    end
  end

  enable :sessions

  # CONNECT TO DB
  env = ENV['RACK_ENV'] || 'development'
  # DB = Sequel.connect('mysql2://root:pass@mysql.getapp.docker/todo')
  DB = Sequel.connect(YAML.load(File.open('db/database.yml'))[env])

  # Do not throw exception is model cannot be saved. Just return nil
  Sequel::Model.raise_on_save_failure = false

  # Sequel plugins loaded by ALL models.
  Sequel::Model.plugin :validation_helpers

  # IMPORT FILES (MODELS & ROUTES)
  Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each { |model| require model }
  Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |lib| load lib }
end
