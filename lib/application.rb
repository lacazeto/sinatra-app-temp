class Todo < Sinatra::Application
  before do
    if !%w[login signup].include?(request.path_info.split('/')[1]) && session[:user_id].nil?
      redirect '/login'
    end
    @user ||= User.first(id: session[:user_id]) if session[:user_id]
  end
end
