class CreateStorageMoves < ActiveRecord::Migration[6.0]
  def change
    create_table :storage_moves do |t|
      t.belongs_to :game
      t.integer :turn
      t.string :snake_version
      t.string :decision
      t.text :state
      t.text :evaluations

      t.decimal :runtime, precision: 15, scale: 9

      t.timestamps
    end
  end
end
