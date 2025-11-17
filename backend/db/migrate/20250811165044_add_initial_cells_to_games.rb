class AddInitialCellsToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :initial_cells, :text
  end
end
