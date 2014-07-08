class Entry < ActiveRecord::Base
  attr_accessible :status, :tiebreak, :user_id, :week_id
  attr :picks
  validates :status, presence: true, inclusion: { in: %w(NEW INCOMPLETE COMPLETE LOCKED), message: "%{value} is not NEW, INCOMPLETE, COMPLETE or LOCKED" }
  validates :user_id, presence: true

  belongs_to :user
  belongs_to :week
  #has_many :picks, dependent: :destroy

  before_save do
    self.details = create_json
  end

  class P
    attr_accessor :points, :pick, :game
    def initialize game, i
      @points = i
      @pick = "NONE"
      @game = game
    end
  end

  def create_json
    "{}" if !@picks
    temp = {}
    @picks.each do |p|
      t = 'NONE'
      t = p.game.home_team.code if p.pick == "HOME"
      t = p.game.away_team.code if p.pick == "AWAY"
      temp[p.points] = t
    end
    JSON.generate temp
  end

  # todo: make these private
  def create_picks
    @picks = []
    week.games.each_with_index do |g, i|
      @picks.append P.new g, i+1
    end
    if details
      (JSON.parse details).each do |points,code|
        # team = Team.find_by_code code
        # game = Game.find_by_home_team_id_and_week_id team.id, week.id
        # game = Game.find_by_away_team_id_and_week_id team.id, week.id if !game
        game = Game.by_team_code_and_week code, week
        if game
          @picks.each do |p|
            if p.game.id == game.id
              p.points = points.to_i
              p.pick = "HOME" if code == game.home_team.code
              p.pick = "AWAY" if code == game.away_team.code 
            end
          end
        end
      end
    end
    @picks
  end

  def picks
    #return "picks exist" if @picks
    @picks ? @picks : create_picks
  end

  def get_points
  	points = 0
  	picks.each do |p|
  		g = p.game
  		next unless g.status == 'COMPLETE'
  		hp = g.home_points ? g.home_points : 0
  		ap = g.away_points ? g.away_points : 0
  		case p.pick
  		when 'HOME'
  			points += p.points if hp > ap
  			points += p.points/2.0 if hp == ap
  		when 'AWAY'
  			points += p.points if ap > hp
  			points += p.points/2.0 if ap == hp
  		end
  	end

  	points
  end
end
