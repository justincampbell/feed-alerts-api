class CreateSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :subscriptions do |t|
      t.references :user, foreign_key: true
      t.references :feed, foreign_key: true
      t.boolean :include_title, default: false, null: false
      t.boolean :shorten_common_terms, default: false, null: false

      t.timestamps
    end
  end
end
