class ChangeEventsToPolymorphicResource < ActiveRecord::Migration[5.1]
  def change
    remove_index :events, :user_id
    add_column :events, :resource_type, :string
    Event.update_all resource_type: "users"
    change_column :events, :resource_type, :string, null: false
    rename_column :events, :user_id, :resource_id
    add_index :events, [:resource_type, :resource_id]
    remove_foreign_key :events, :users
  end
end
