class Todo < Sinatra::Application
  before do
    redirect '/login' if !%w[login signup].include?(request.path_info.split('/')[1]) && session[:user_id].nil?

    # get user before every route if session exists.
    @user ||= User.first(id: session[:user_id]) if session[:user_id]
  end
end
