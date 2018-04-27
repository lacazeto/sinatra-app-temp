class Todo < Sinatra::Application
  get '/?' do
    @my_lists = List.association_join(:permissions).where(user_id: @user.id, permission_level: 'read_write')
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
    list_creation = List.new_list params[:list_name], params[:items], params[:shared_with], @user
    @time = Time.now.strftime('%F')
    if list_creation.class == List
      flash.next[:comment] = Todo.flash_prepare ['List created!']
      flash.next[:positive] = 'not nil'
      redirect '/'
    elsif list_creation.nil?
      flash.now[:list] = Todo.flash_prepare ['Choose a due date from today and onwards']
      slim :'/new_list'
    else
      flash.now[:list] = Todo.flash_prepare list_creation
      slim :'/new_list'
    end
  end

  get '/edit/:id/?' do
    @list = List.association_join(:items).where(list_id: params[:id]).first
    @list[:id] = @list[:list_id] # temporary fix
    if !@list.nil? && (User.can_interact? @list, @user[:id])
      @time = Time.now.strftime('%F')
      @items = Item.where(list_id: params[:id]).order(Sequel.desc(:starred))
      @comments = @list.comments_dataset.eager(:user)
      @can_edit = User.can_edit_list? @list[:list_id], @user[:id]
      slim :'/edit_list'
    else
      @message = 'This list is unavailable or doesn´t exist'
      slim :'/error'
    end
  end

  post '/edit/:id' do
    @list = List.association_join(:items).where(list_id: params[:id]).first
    if !@list.nil? && (User.can_edit_list? @list[:list_id], @user[:id])
      List.edit_list params[:id], params[:list_name], params[:shared_with], params[:items], @user
      redirect '/'
    else
      flash.next[:list] = Todo.flash_prepare ['Not enough permissions to perform this action.']
      redirect back
    end
  end

  post '/permission/:id' do
    list = List.association_join(:items).where(list_id: params[:id]).first
    if User.can_edit_list? list[:list_id], params[:owner].to_i
      new_permission_result = Permission.update params[:user_affected], list[:list_id]
      if new_permission_result.class == Permission
        flash.next[:permission] = Todo.flash_prepare ['Permissions updated.']
        flash.next[:positive] = 'not nil'
      else
        flash.next[:permission] = Todo.flash_prepare new_permission_result
      end
      redirect '/'
    else
      @message = 'Invalid permissions'
      slim :'/error'
    end
  end

  get '/comments/:id/?' do
    @list = List.association_join(:items).where(list_id: params[:id]).first
    if User.can_interact? @list, @user[:id]
      slim :new_comment
    else
      @message = 'Not enough permissions'
      slim :'/error'
    end
  end

  post '/comments/:id/?' do
    list = List.association_join(:items).where(list_id: params[:id]).first
    # returns nil if user cannot interact with this list
    comment = Comment.new_comment list, session[:user_id], params[:comment]
    if !comment.nil?
      if comment.save
        flash.next[:comment] = Todo.flash_prepare ['Comment posted with success']
        flash.next[:positive] = 'not nil'
        redirect '/'
      else
        flash.next[:comment] = Todo.flash_prepare comment.errors.on(:text)
        redirect back
      end
    else
      flash.next[:comment] = Todo.flash_prepare ['Comment submission failed. Not enough permissions.']
      redirect back
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
      flash.next[:list] = Todo.flash_prepare ['List deleted']
      flash.next[:positive] = 'not nil'
      redirect back
    else
      @message = 'Invalid permissions. You are not allowed to delete this.'
      slim :'/error'
    end
  end
end
