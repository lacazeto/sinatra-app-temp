Sequel.migration do 
     change do 
          create_table :lists do 
               primary_key :id
               foreign_key :user_id, :users, :null => false 
               foreign_key :list_id, :lists, :null => false
               String :text, :length => 256, :null => false  
               DateTime :creation_date, :null => false
          end 
     end 
end 