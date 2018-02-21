class AddKindAndCreatedByToFeed < ActiveRecord::Migration[5.1]
  def change
    add_column :feeds, :kind, :string
    add_reference :feeds, :created_by, foreign_key: { to_table: :users }
  end
end
