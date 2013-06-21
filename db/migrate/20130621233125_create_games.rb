class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :week_id
      t.integer :home_team_id
      t.integer :away_team_id
      t.integer :home_points
      t.integer :away_points
      t.datetime :start

      t.timestamps
    end
  end
end
