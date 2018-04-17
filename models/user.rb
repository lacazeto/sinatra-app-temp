require 'sequel'

class User < Sequel::Model
  set_primary_key :id

  one_to_many :items
  one_to_many :permissions
  one_to_many :logs

  attr_accessor :new_password

  def before_save
    self.password = Digest::MD5.hexdigest new_password if new_password
  end

  def self.find_by_login name, password
    md5sum = Digest::MD5.hexdigest password
    User.first(name: name, password: md5sum)
  end

  def validate
    super
    validates_presence [:name]
    validates_format /\A[A-Za-z]/, :name, message: 'is not a valid name'
    validates_min_length 3, :name
    validates_max_length 8, :name
    validates_unique :name

    if new_password
      validates_min_length 3, :new_password
    end
  end
end
