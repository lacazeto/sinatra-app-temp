class Item < Sequel::Model
  set_primary_key :id

  many_to_one :user
  many_to_one :list

  def self.new_item(item, list, user)
    unless item[:name].empty?
      return false if Date.parse(item[:due_date]) < (DateTime.now - 1)
      item[:starred] = false if item[:starred].nil?
      Item.create(name: item[:name], description: item[:description], starred: item[:starred],
                  list_id: list[:id], user_id: user[:id], due_date: item[:due_date], created_at: Time.now,
                  updated_at: Time.now)
    end
  end
end
