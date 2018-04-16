class Todo < Sinatra::Application
  get '/signup/?' do
    if session[:user_id].nil?
      slim :'/signup'
    else
      @message = 'Please log out first'
      slim :'error'
    end
  end

  post '/signup/?' do
    check = User.first(name: params[:name])
    if check.nil?
      user = User.new(name: params[:name], new_password: params[:password])
      if user.save
        session[:user_id] = user.id
        redirect '/'
      else
        slim :'/signup'
      end
    else
      @message = 'This Username already exists'
      slim :'error'
    end
  end

  get '/login/?' do
    if session[:user_id].nil?
      slim :'/login'
    else
    @message = 'Please log out first'
      slim :'error'
    end
  end

  post '/login/?' do
    md5sum = Digest::MD5.hexdigest params[:password]
    user = User.first(name: params[:name], password: md5sum)
    if user.nil?
      @message = 'Invalid login credentials'
      slim :'error'
    else
      session[:user_id] = user.id
      @is_not_logged = false
      redirect '/'
    end
  end

  get '/logout/?' do
    session[:user_id] = nil
    @is_not_logged = true
    # session.clear can also be used
    redirect '/login'
  end
end
