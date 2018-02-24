class AddUniquenessIndexToFeeds < ActiveRecord::Migration[5.1]
  def change
    add_index :feeds, [:url], unique: true
  end
end
