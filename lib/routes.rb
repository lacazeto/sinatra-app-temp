get '/test' do
     return 'The application is running'
end

get '/?' do 
     @all_lists =  List.all 

     slim :'/index'
end

get '/new/?' do 
     slim :'/new_list'
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