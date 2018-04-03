require 'sinatra'
require 'sinatra/base'
require 'sequel'
require 'slim'
require 'yaml'
require 'digest'
require 'sinatra/reloader'

class Todo < Sinatra::Application
     # CONFIG APP
     configure do
          set :environment, :development # ENV['RACK_ENV']
          register Sinatra::Reloader
          enable :reloader
          also_reload 'lib/*.rb'
          also_reload 'models/*.rb'
          after_reload do
               puts 'Reloaded'
          end

          # CONNECT TO DB
          env = ENV['RACK_ENV'] || 'development'
          # DB = Sequel.connect('mysql2://root:pass@mysql.getapp.docker/todo')
          DB = Sequel.connect(YAML.load(File.open('db/database.yml'))[env])
          
          # IMPORT FILES (MODELS & ROUTES)
          Dir[File.join(File.dirname(__FILE__),'models','*.rb')].each { |model| require model }
          Dir[File.join(File.dirname(__FILE__),'lib','*.rb')].each { |lib| load lib }
          enable :sessions
     end
end