class AddIncludeFeedNameAndIncludeLinkToSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :subscriptions, :include_feed_name, :boolean, default: false, null: false
    add_column :subscriptions, :include_link, :boolean, default: true, null: false
  end
end
