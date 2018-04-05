require 'sinatra'
require 'date'
require 'pry'
require 'byebug'

@is_not_logged = true

before do
      if !['login', 'signup'].include?(request.path_info.split('/')[1]) and session[:user_id].nil?
            redirect '/login'
      end
      @user = User.first(id: session[:user_id]) if session[:user_id]
end

get '/?' do 
      @my_lists = List.association_join(:permissions).where(user_id: @user.id)
      @others_lists = List.association_join(:permissions).exclude(user_id: @user.id)
      @list_names = ["My Lists", "Others Lists"]
      slim :'/index'
end

get '/new/?' do 
      # @time = (DateTime.now).to_s.gsub!(/T\d{2}.*/,'') #check for strftime method
      @time = (DateTime.now).strftime("%F")
      slim :'/new_list'
end

post '/new/?' do 
      list = List.new_list params[:name], params[:items], @user
      redirect "/"
end

get '/edit/:id/?' do 
     @list = List.first(id: params[:id])
     can_edit = true
     if @list.nil?
          can_edit = false
     elsif @list.shared_with == 'public'
          user = User.first(id: session[:user_id])
          permission = Permission.first(list: @list, user: @user)
          if permission.nil? or permission.permission_level == 'read_only'
               can_edit = false
          end
     end

     if can_edit
          @time = (DateTime.now).strftime("%F")
          @items = Item.where(list_id: params[:id]).order(Sequel.desc(:starred))
          slim :'/edit_list'
     else
          halt 403, 'Invalid permissions'
          # haml :error, locals: {error: 'Invalid permissions'}
     end
end

post '/edit/:id' do
     List.edit_list params[:id], params[:name], params[:items], @user
     redirect '/'
end

post '/permission/?' do 
    	list = List.first(id: params[:id])
    	can_change_permission = true
    	
    	if list.nil?
    	     can_change_permission = false
    	elsif list.shared_with != 'public'
          permission = Permission.first(list: list, user: @user)
    	     if permission.nil? or permission.permission_level == 'read_only'
    	          can_change_permission = false
    	     end
    	end
    	
    	if can_change_permission
          list.permission = params[:new_permissions]
          list.save

          current_permissions = Permission.first(list: list)
          current_permissions.each do |perm|
               perm.destroy
          end
    	
          if params[:new_permissions] == 'private' or parms[:new_permissions] == 'shared'
               user_perms.each do |perm|
                    u = User.first(perm[:user])
                    Permission.create(list: list, user: u, permission_level: perm[:level], created_at: Time.now, updated_at: Time.now)
               end
    	     end
    	     redirect request.referer
     else
          halt 403, 'Invalid permissions'
    	     # haml :error, locals: {error: 'Invalid permissions'}
    	end
end

get '/delete/:id/?' do
      list = List.first(id: params[:id])
      # items = Item.where(list_id: params[:id])
      # permission = Permission.first(list_id: params[:id])
      # permission.destroy
      # items.each {|item| item.destroy}
      list.destroy
      redirect '/'
end

get '/signup/?' do 
      if session[:user_id].nil?
          slim :'/signup'
       else
          @message = "Please log out first"
          slim :'error'
      end
end 
     
post '/signup/?' do 
     md5sum = Digest::MD5.hexdigest params[:password]
     User.create(name: params[:name], password: md5sum)
     user = User.first(name: params[:name], password: md5sum)
     session[:user_id] = user.id
     redirect '/'
end

get '/login/?' do 
      if session[:user_id].nil?
          slim :'/login'
      else
          @message = "Please log out first"
          slim :'error' #, locals: {error: 'Please log out first'}
      end
end 
     
post '/login/?' do
      md5sum = Digest::MD5.hexdigest params[:password]
      user = User.first(name: params[:name], password: md5sum)
      if user.nil?
            @message = "Invalid login credentials"
            slim :'error'
      else
            session[:user_id] = user.id
            redirect '/'
      end
end

get '/logout/?' do
      session[:user_id] = nil
      # session.clear can also be used
	redirect '/login'
end