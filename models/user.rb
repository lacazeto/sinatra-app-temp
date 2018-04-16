require 'sequel'

class User < Sequel::Model
  set_primary_key :id

  one_to_many :items
  one_to_many :permissions
  one_to_many :logs

  attr_accessor :new_password

  def before_save
    if new_password
      self.password = Digest::MD5.hexdigest new_password
    end
  end
end
