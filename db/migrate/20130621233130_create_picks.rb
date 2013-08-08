class CreatePicks < ActiveRecord::Migration
  def change
    create_table :picks do |t|
      t.integer :entry_id
      t.integer :game_id
      t.string :pick
      t.integer :points

      t.timestamps
    end
    add_index :picks, [:entry_id, :game_id], unique: true
    add_index :picks, :game_id
  end
end
