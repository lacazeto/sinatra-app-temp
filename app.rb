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

get '/?' do 
     @all_lists =  List.all 

     slim :'/index'
end

get '/new/?' do 
     # show create list page 
end

post '/new/?' do 
	# save the list 
end

get '/edit/:id/?' do 
     # check user permission and show the edit page 
end

post '/edit/?' do
     # update the list 
end

post '/permission/?' do 
     # update permission 
end

get '/signup/?' do 
     # show signup form 
end 
     
post '/signup/?' do 
     # save the user data 
end

get '/login/?' do 
     # show a login page 
end 
     
post '/login/?' do 
     # validate user credentials 
end