class CreateFeeds < ActiveRecord::Migration[5.1]
  def change
    enable_extension 'citext'

    create_table :feeds do |t|
      t.string :url, null: false
      t.citext :name, null: false

      t.timestamps
    end
  end
end
