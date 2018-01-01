class CreateFeedItems < ActiveRecord::Migration[5.1]
  def change
    create_table :feed_items do |t|
      t.references :feed, foreign_key: true, null: false, index: true
      t.string :guid, null: false, index: true
      t.string :title
      t.string :link
      t.string :author
      t.text :content
      t.timestamps
      t.string :published_at
    end

    add_index :feed_items, [:feed_id, :guid], unique: true
  end
end
