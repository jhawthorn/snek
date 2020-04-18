class AddMoveDataToGame < ActiveRecord::Migration[6.0]
  def change
    add_column :storage_games, :move_data, :binary
  end
end
