class CreateWeeks < ActiveRecord::Migration
  def change
    create_table :weeks do |t|
      t.integer :week_num
      t.integer :num_games
      t.integer :season_id
      t.integer :tiebreak_game_id

      t.timestamps
    end
  end
end
