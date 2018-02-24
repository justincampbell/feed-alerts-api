class AddCharacterLimitToSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :subscriptions, :character_limit, :integer, default: 1600, null: false
  end
end
