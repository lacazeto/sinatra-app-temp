require 'sequel' 
     
class List < Sequel::Model 
     set_primary_key :id 
     
     one_to_many :items 
     one_to_many :permissions 
     one_to_many :logs 
end

class Item < Sequel::Model
     set_primary_key :id 
     	 
     many_to_one :user 
     many_to_one :list 
end