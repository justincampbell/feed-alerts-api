class AddUniquenessIndexToSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_index :subscriptions, [:user_id, :feed_id], unique: true
  end
end
