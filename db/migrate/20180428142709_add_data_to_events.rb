class AddDataToEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :data, :json, null: false, default: {}
  end
end
