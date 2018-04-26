class Item < Sequel::Model
  set_primary_key :id

  many_to_one :user
  many_to_one :list

  def before_save
    self.updated_at = Time.now
  end

  def self.new_item(item, list, user)
    unless item[:due_date].empty?
      return false if Date.parse(item[:due_date]) < (DateTime.now - 1)
    end
    if item[:name].empty?
      i = Item.first(id: item[:id])
      i.destroy unless i.nil?
    else
      item[:starred] = false if item[:starred].nil?
      i = Item.first(id: item[:id])
      if i.nil?
        Item.create(name: item[:name], description: item[:description], starred: item[:starred],
                    list_id: list[:id], user_id: user[:id], due_date: item[:due_date], created_at: Time.now)
      else
        i.name = item[:name]
        i.description = item[:description]
        i.starred = item[:starred]
        i.due_date = item[:due_date]
        i.save
      end
    end
  end
end
