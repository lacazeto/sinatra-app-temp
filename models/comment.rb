class Comment < Sequel::Model
  set_primary_key :id

  many_to_one :list
  many_to_one :user

  def self.new_comment(list, user, content, list_is_public)
    Comment.create(list_id: list.to_i, user_id: user, text: content, creation_date: Time.now) if
      list.to_i == user || list_is_public == 'public'
  end

  def self.delete(comment_id, user_id)
    comment = Comment.first(id: comment_id)
    return comment.destroy if user_id == comment[:user_id] && (comment[:creation_date] + 60 * 15) >= Time.now
    false
  end
end
