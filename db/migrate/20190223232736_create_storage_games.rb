class CreateStorageGames < ActiveRecord::Migration[6.0]
  def change
    create_table :storage_games do |t|
      t.string :external_id, null: false
      t.string :snake_version, null: false

      t.boolean :victory

      t.timestamps
    end
  end
end
