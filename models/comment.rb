class Comment < Sequel::Model
  set_primary_key :id

  many_to_one :list
  many_to_one :user

  def validate
    super
    validates_presence [:text], message: 'Don´t leave comment area in blank'
  end

  def self.new_comment(list, user, content)
    Comment.new(list_id: list[:list_id], user_id: user, text: content, creation_date: Time.now) if
      User.can_interact? list, user
  end

  def self.delete(comment_id, user_id)
    comment = Comment.first(id: comment_id)
    if user_id == comment[:user_id] && (comment[:creation_date] + 60 * 15) >= Time.now
      comment.destroy
    else
      false
    end
  end
end
