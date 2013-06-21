class Game < ActiveRecord::Base
  attr_accessible :away_points, :away_team_id, :home_points, :home_team_id, :start, :week_id
end
