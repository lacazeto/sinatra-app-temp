require 'sinatra'
require 'sequel'
require 'slim'
require 'yaml'
require 'digest'
require 'digest/md5'

class Todo < Sinatra::Base
     set :environment, :development #ENV['RACK_ENV']
     enable :sessions

     configure do
          env = 'development' #ENV['RACK_ENV']
          # DB = Sequel.connect('mysql2://root:pass@mysql.getapp.docker/todo')
          DB = Sequel.connect(YAML.load(File.open('db/database.yml'))[env])
     end
     Dir[File.join(File.dirname(__FILE__),'models','*.rb')].each { |model| require model }
     Dir[File.join(File.dirname(__FILE__),'lib','*.rb')].each { |lib| load lib }
end