Sequel.migration do
  change do
    create_table :lists do
      primary_key :id
      String :name, length: 32, null: false
      column :shared_with, 'enum("private", "public")', null: false, default: 'private'
      DateTime :created_at
      DateTime :updated_at
    end
  end
end

# Sequel.migration do
#      change do
#           alter_table(:lists) {add_column :public, TrueClass, :null => false, :default => false}
#      end
# end
