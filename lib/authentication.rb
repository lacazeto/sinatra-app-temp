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
        flash.now[:user] = Todo.flash_prepare @user.errors.on(:name)
        flash.now[:pass] = Todo.flash_prepare @user.errors.on(:new_password)
        slim :'/signup'
      end
    else
      flash.now[:user] = Todo.flash_prepare ['This username is already in use']
      slim :'/signup'
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
      flash.now[:user] = Todo.flash_prepare ['Invalid login credentials']
      slim :'/login'
    else
      session[:user_id] = user.id
      redirect '/'
    end
  end

  get '/logout/?' do
    # session[:user_id] = nil
    session.clear
    redirect '/login'
  end
end
