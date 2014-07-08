class Game < ActiveRecord::Base
  #attr_accessible :status, :away_points, :away_team_id, :home_points, :home_team_id, :start, :week_id, :tiebreak, :home_team, :away_team
  validates :status, presence: true, inclusion: { in: %w(NOT_STARTED STARTED COMPLETE), message: "%{value} is not NOT_STARTED STARTED or COMPLETE" }

  validates :away_team_id, presence: true

  validates :home_team_id, presence: true
  validates :start, presence: true
  validates :week_id, presence: true
  validates_inclusion_of :tiebreak,:in => [true, false]

  belongs_to :week
  belongs_to :home_team, class_name: "Team", inverse_of: :home_games
  belongs_to :away_team, class_name: "Team", inverse_of: :away_games
  #has_many :picks

  class << self
    def by_team_code_and_week code, week
      team = Team.find_by_code code
      return if !team
      game = find_by_home_team_id_and_week_id team.id, week.id
      game = find_by_away_team_id_and_week_id team.id, week.id if !game
      game
    end
  end

end
