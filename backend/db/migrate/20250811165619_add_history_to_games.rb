class AddHistoryToGames < ActiveRecord::Migration[8.0]
  def change
    add_column :games, :history, :text
  end
end
