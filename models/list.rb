require 'sequel' 
     
class List < Sequel::Model 
     set_primary_key :id 
     
     one_to_many :items 
     one_to_many :permissions 
     one_to_many :logs 

     def self.new_list name, items, user
          list = List.create(name: name, created_at: Time.now, updated_at: Time.now)
          items.each do |item|
               unless item[:name].empty?
                    item[:starred] = false if item[:starred] == nil
                    Item.create(name: item[:name], description: item[:description], starred: item[:starred],
                         list: list, user: user, due_date: item[:due_date], created_at: Time.now, updated_at: Time.now)
               end
          end
          Permission.create(list: list, user: user, permission_level: 'read_write', created_at: Time.now, updated_at: Time.now)
          return list
     end

     def self.edit_list id, name, items, user
          list = List.first(id: id)
          list.name = name
          list.updated_at = Time.now
          list.save
          
          items.each do |item|
               if item[:name].empty?
                    begin
                         i = Item.first(id: item[:id]).destroy
                    rescue
                         puts "inexistent item"
                    end
                    next
               else
                    item[:starred] = false if item[:starred].nil?
                    i = Item.first(id: item[:id])
                    if i.nil?
                         Item.create(name: item[:name], description: item[:description], starred: item[:starred], list: list, user: user, created_at: Time.now, updated_at: Time.now)
                    else  
                         i.name = item[:name]
                         i.description = item[:description]
                         i.updated_at = Time.now
                         i.starred = item[:starred]
                         i.save
                    end
               end
          end
     end
end

class Item < Sequel::Model
     set_primary_key :id 
     	 
     many_to_one :user 
     many_to_one :list 
end