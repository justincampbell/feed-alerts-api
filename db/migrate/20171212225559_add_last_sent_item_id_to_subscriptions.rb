class AddLastSentItemIdToSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :subscriptions, :last_sent_item_id, :string
  end
end
