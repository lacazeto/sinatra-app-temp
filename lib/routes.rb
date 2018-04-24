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
    if List.new_list params[:list_name], params[:items], params[:shared_with], @user
      redirect '/'
    else
      @message = 'List must contain at least one item to be created'
      slim :'/error'
    end
  end

  get '/edit/:id/?' do
    @list = List.first(id: params[:id])
    if User.can_view_list? @list
      @time = Time.now.strftime('%F')
      @items = Item.where(list_id: params[:id]).order(Sequel.desc(:starred))
      @comments = @list.comments_dataset.eager(:user)
      @can_edit = User.can_edit_list? @list[:id], @user[:id]
      slim :'/edit_list'
    else
      @message = 'This list is unavailable'
      slim :'/error'
    end
  end

  post '/edit/:id' do
    @list = List.first(id: params[:id])
    if User.can_edit_list? @list[:id], @user[:id]
      List.edit_list params[:id], params[:list_name], params[:shared_with], params[:items], @user
      redirect '/'
    else
      @message = 'Not enough permissions'
      slim :'/error'
    end
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
      slim :'/error'
      # halt 403
    end
  end

  get '/comments/:id/?' do
    @list = List.association_join(:items).where(list_id: params[:id]).first
    if User.can_comment? @list, @user[:id]
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
    if User.can_edit_list? list[:id], @user[:id]
      list.destroy
      redirect '/'
    else
      @message = 'Invalid permissions. You are not allowed to delete this.'
      slim :'/error'
    end
  end
end
