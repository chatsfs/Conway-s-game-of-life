class CreateGames < ActiveRecord::Migration[8.0]
  def change
    create_table :games do |t|
      t.integer :width, null: false
      t.integer :height, null: false
      t.integer :generation, default: 0
      t.text :cells

      t.timestamps
    end
  end
end
