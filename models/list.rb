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
    return ['List and item names are required'] if items.all? { |item| item[:name].empty? } || name.empty?
    shared_with = shared_with.nil? ? 'private' : 'public'
    Todo.db.transaction do
      list = List.create(list_name: name, created_at: Time.now, updated_at: Time.now, shared_with: shared_with)
      raise Sequel::Rollback unless items.all? { |item| Item.new_item item, list, user }
      Permission.create(list: list, user: user, permission_level: 'read_write', created_at: Time.now,
                        updated_at: Time.now)
      list
    end
    # return nil if transaction fails
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
      Item.new_item item, list, user
    end
  end
end
