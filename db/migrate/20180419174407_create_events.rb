class CreateEvents < ActiveRecord::Migration[5.1]
  def change
    create_table :events do |t|
      t.datetime :created_at, null: false
      t.references :user, foreign_key: true, null: false
      t.string :code, null: false
      t.text :detail
    end
  end
end
