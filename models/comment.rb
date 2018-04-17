class Comment < Sequel::Model
  set_primary_key :id

  many_to_one :list
  many_to_one :user

  def self.new_comment(list_owner, user, content, list_is_public)
    if list_owner.to_i == user || list_is_public == 'public'
      Comment.create(list_id: list_owner.to_i, user_id: user, text: content, creation_date: Time.now)
    end
  end
end
