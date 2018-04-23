Sequel.migration do
  change do
    alter_table(:lists) { rename_column :name, :list_name }
  end
end
