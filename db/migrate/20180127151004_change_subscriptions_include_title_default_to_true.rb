class ChangeSubscriptionsIncludeTitleDefaultToTrue < ActiveRecord::Migration[5.1]
  def up
    change_column :subscriptions, :include_title, :boolean, default: true, null: false
  end

  def down
    change_column :subscriptions, :include_title, :boolean, default: false, null: false
  end
end
