class Todo < Sinatra::Application
  before do
    # get user before every route if session exists.
    @user ||= User.first(id: session[:user_id]) if session[:user_id]

    redirect '/login' if !%w[login signup].include?(request.path_info.split('/')[1]) && session[:user_id].nil?
  end

  def self.flash_prepare(errors)
    errors.nil? ? {} : errors.uniq.join('. ').to_s
  end

  def self.db
    DB
  end
end
