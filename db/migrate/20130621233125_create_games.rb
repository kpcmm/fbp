class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :week_id
      t.string :status
      t.integer :home_team_id
      t.integer :away_team_id
      t.integer :home_points
      t.integer :away_points
      t.datetime :start
      t.boolean :tiebreak

      t.timestamps
    end
    add_index :games, :week_id
    add_index :games, :home_team_id
    add_index :games, :away_team_id
  end
end
