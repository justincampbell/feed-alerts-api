class AddErrorToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :error, :boolean, default: false, null: false
  end
end
