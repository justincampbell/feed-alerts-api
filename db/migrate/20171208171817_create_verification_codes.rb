class CreateVerificationCodes < ActiveRecord::Migration[5.1]
  def change
    create_table :verification_codes do |t|
      t.string :destination, null: false
      t.string :code, null: false

      t.timestamps
    end
  end
end
