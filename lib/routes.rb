class Todo < Sinatra::Application
  get '/?' do
    @my_lists = List.association_join(:permissions).where(user_id: @user.id)
    @others_lists = List.association_join(permissions: :user).exclude(user_id: @user.id)
    @list_types = ['My Lists', 'Others Lists']
    slim :'/index'
  end

  get '/new/?' do
    # @time = (DateTime.now).to_s.gsub!(/T\d{2}.*/,'') #check for strftime method
    @time = Time.now.strftime('%F')
    slim :'/new_list'
  end

  post '/new/?' do
    List.new_list params[:list_name], params[:items], params[:shared_with], @user
    redirect '/'
  end

  get '/edit/:id/?' do
    @list = List.first(id: params[:id])
    can_view = true
    can_edit = true
    @user = User.first(id: session[:user_id])
    if @list.nil?
      can_view = false
    elsif @list.shared_with == 'public'
      permission = Permission.first(list: @list, user: @user)
      can_edit = false if permission.nil? || permission.permission_level == 'read_only'
    end

    if can_view
      @time = Time.now.strftime('%F')
      @items = Item.where(list_id: params[:id]).order(Sequel.desc(:starred))
      @comments = @list.comments_dataset.eager(:user)
      # @comments = Comment.join_table(:inner, :users, id: :user_id).where(list_id: params[:id])
      # Comment.association_join(:users).where(list_id: params[:id])
      slim :'/edit_list', locals: { can_edit: can_edit }
    else
      @message = 'Invalid permissions'
      slim :'/error'
    end
  end

  post '/edit/:id' do
    List.edit_list params[:id], params[:list_name], params[:shared_with], params[:items], @user
    redirect '/'
  end

  post '/permission/?' do
    list = List.first(id: params[:id])
    can_change_permission = true

    if list.nil?
      can_change_permission = false
    elsif list.shared_with != 'public'
      permission = Permission.first(list: list, user: @user)
      can_change_permission = false if permission.nil? || permission.permission_level == 'read_only'
    end

    if can_change_permission
      list.permission = params[:new_permissions]
      list.save

      current_permissions = Permission.first(list: list)
      current_permissions.each(&:destroy)

      if params[:new_permissions] == 'private' || parms[:new_permissions] == 'shared'
        user_perms.each do |perm|
          u = User.first(perm[:user])
          Permission.create(list: list, user: u, permission_level: perm[:level],
                            created_at: Time.now, updated_at: Time.now)
        end
      end
      redirect request.referer
    else
      @message = 'Invalid permissions'
      halt 403
    end
  end

  get '/comments/:id/?' do
    @list = List.association_join(:items).where(list_id: params[:id]).first
    if @list[:user_id] == session[:user_id] || @list[:shared_with] == 'public'
      slim :new_comment
    else
      @message = 'Not enough permissions'
      slim :'/error'
    end
  end

  post '/comments/:id/?' do
    @comment = Comment.new_comment params[:id], session[:user_id], params[:comment], params[:shared]
    if @comment.save
      redirect '/'
    else
      @message = 'Not enough permissions'
      slim :'/error'
    end
  end

  get '/comments/:id/delete' do
    if Comment.delete params[:id], session[:user_id]
      redirect back
    else
      @message = 'You cannot delete this comment!'
      slim :'/error'
    end
  end

  get '/delete/:id/?' do
    list = List.first(id: params[:id])
    # items = Item.where(list_id: params[:id])
    # permission = Permission.first(list_id: params[:id])
    # permission.destroy
    # items.each {|item| item.destroy}
    permission = Permission.first(list: list, user: @user)
    if permission.nil? || permission.permission_level == 'read_only'
      @message = 'Invalid permissions. You are not allowed to delete this.'
      slim :'/error'
    else
      list.destroy
      redirect '/'
    end
  end
end
