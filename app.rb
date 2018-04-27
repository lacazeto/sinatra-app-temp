require 'sinatra/reloader' if development?

class Todo < Sinatra::Application
  # CONFIG APP
  set :environment, (ENV['RACK_ENV'] || :development).to_sym

  configure :development do
    register Sinatra::Reloader
    enable :reloader
    also_reload 'lib/*.rb'
    also_reload 'models/*.rb'
    after_reload do
      puts "Reloaded: #{Time.now}"
    end
  end

  register Sinatra::Flash

  enable :sessions

  # CONNECT TO DB
  DB = Sequel.connect(YAML.safe_load(File.open('db/database.yml'))[environment.to_s])

  # Do not throw exception if model cannot be saved. Just return nil
  Sequel::Model.raise_on_save_failure = false

  # Sequel plugins loaded by ALL models.
  Sequel::Model.plugin :validation_helpers

  # Use this for middleware to simulate other actions such as PUT, PATCH or DELETE via HTML forms.
  # use Rack::MethodOverride

  # IMPORT FILES (MODELS & ROUTES)
  Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each { |model| require model }
  Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |lib| load lib }
end
