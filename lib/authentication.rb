class Todo < Sinatra::Application
  get '/signup/?' do
    if session[:user_id].nil?
      @user = User.new
      slim :'/signup'
    else
      @message = 'Please log out first'
      slim :'/error'
    end
  end

  post '/signup/?' do
    check = User.first(name: params[:name])
    if check.nil?
      @user = User.new(name: params[:name], new_password: params[:password])
      if @user.save
        session[:user_id] = @user.id
        redirect '/'
      else
        slim :'/signup'
      end
    else
      @message = 'This Username already exists'
      slim :'/error'
    end
  end

  get '/login/?' do
    if session[:user_id].nil?
      slim :'/login'
    else
      @message = 'Please log out first'
      slim :'/error'
    end
  end

  post '/login/?' do
    user = User.find_by_login(params[:name], params[:password])
    if user.nil?
      @message = 'Invalid login credentials'
      slim :'/error'
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
end
