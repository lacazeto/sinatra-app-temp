require 'sequel'

class User < Sequel::Model
  set_primary_key :id

  one_to_many :items
  one_to_many :permissions
  one_to_many :logs
  one_to_many :comments

  attr_accessor :new_password

  def before_save
    self.password = Digest::MD5.hexdigest new_password if new_password
    self.created_at ||= Time.now
  end

  def self.find_by_login(name, password)
    md5sum = Digest::MD5.hexdigest password
    User.first(name: name, password: md5sum)
  end

  def validate
    super
    validates_presence [:name], message: 'Username must contain between 3 and 8 characters'
    validates_format(/\A[A-Za-z1-9]/, :name, message: 'It is not a valid name')
    validates_min_length 3, :name, message: 'Username must contain between 3 and 8 characters'
    validates_max_length 8, :name, message: 'Username must contain between 3 and 8 characters'
    validates_unique :name

    validates_min_length 3, :new_password, message: 'Password must have at least 3 characters' if new_password
  end

  def self.can_interact?(list, user)
    return false if list.nil?
    return true if list[:user_id] == user || list[:shared_with] == 'public'
    false
  end

  def self.can_edit_list?(list, user)
    permission = Permission.first(list_id: list, user_id: user)
    return false if permission.nil? || permission[:permission_level] == 'read_only'
    true
  end
end
