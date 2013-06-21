class Week < ActiveRecord::Base
  attr_accessible :num_games, :season_id, :tiebreak_game_id, :week_num
end
