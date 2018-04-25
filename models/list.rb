require 'sequel'

class List < Sequel::Model
  set_primary_key :id

  one_to_many :items
  one_to_many :permissions
  one_to_many :logs
  one_to_many :comments

  def before_destroy
    comments.each(&:destroy)
    items.each(&:destroy)
    permissions.each(&:destroy)
    logs.each(&:destroy)
    super
  end

  def self.new_list(name, items, shared_with, user)
    return false if items.all? { |item| item[:name].empty? } || name.empty?
    shared_with = shared_with.nil? ? 'private' : 'public'
    list = List.create(list_name: name, created_at: Time.now, updated_at: Time.now, shared_with: shared_with)
    items.each { |item| Item.new_item item, list, user }
    Permission.create(list: list, user: user, permission_level: 'read_write', created_at: Time.now,
                      updated_at: Time.now)
    list
  end

  def self.edit_list(id, name, shared_with, items, user)
    shared_with = shared_with.nil? ? 'private' : 'public'
    list = List.first(id: id)
    return list.destroy if items.all? { |item| item[:name].empty? }
    list.list_name = name
    list.updated_at = Time.now
    list.shared_with = shared_with
    list.save

    items.each do |item|
      if item[:name].empty?
        i = Item.first(id: item[:id])
        i.destroy unless i.nil?
      else
        item[:starred] = false if item[:starred].nil?
        i = Item.first(id: item[:id])
        if i.nil?
          Item.create(name: item[:name], description: item[:description], starred: item[:starred], list: list,
                      due_date: item[:due_date], user: user, created_at: Time.now, updated_at: Time.now)
        else
          i.name = item[:name]
          i.description = item[:description]
          i.updated_at = Time.now
          i.starred = item[:starred]
          i.due_date = item[:due_date]
          i.save
        end
      end
    end
  end
end
