require 'sinatra'
require 'sequel'


class Todo < Sinatra::Base
     set :environment, ENV['RACK_ENV']

     configure do
          DB = Sequel.connect('mysql2://root:pass@mysql.getapp.docker/todo')

          Dir[File.join(File.dirname(__FILE__),'models','*.rb')].each { |model| require model }
          Dir[File.join(File.dirname(__FILE__),'lib','*.rb')].each { |lib| load lib }
     end
end
