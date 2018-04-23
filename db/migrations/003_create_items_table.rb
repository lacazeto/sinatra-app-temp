Sequel.migration do
  change do
    create_table :items do
      primary_key :id
      String :name, length: 128, null: false
      String :description, length: 256
      TrueClass :starred, null: false, default: false
      foreign_key :user_id, :users, null: false
      foreign_key :list_id, :lists, null: false
      DateTime :created_at, null: false
      DateTime :updated_at
      DateTime :due_date
    end
  end
end
