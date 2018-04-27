require 'sequel'

class Permission < Sequel::Model
  many_to_one :user
  many_to_one :list

  def before_save
    self.updated_at = Time.now
  end

  def self.update(name, list_id)
    available_permissions = { 'read_only' => 'read_write', 'read_write' => 'read_only' }
    user_affected = User.first(name: name)
    return ['User not found'] if user_affected.nil?
    permission = Permission.first(list_id: list_id, user_id: user_affected[:id])
    if permission.nil?
      list = List.first(id: list_id)
      Permission.create(user: user_affected, list: list, permission_level: 'read_write',
                        created_at: Time.now)
    else
      permission[:permission_level] = available_permissions[permission[:permission_level]]
      permission.save
      return permission
    end
  end
end
