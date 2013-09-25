class Entry < ActiveRecord::Base
  attr_accessible :status, :tiebreak, :user_id, :week_id
  validates :status, presence: true, inclusion: { in: %w(NEW INCOMPLETE COMPLETE LOCKED), message: "%{value} is not NEW, INCOMPLETE, COMPLETE or LOCKED" }
  validates :user_id, presence: true

  belongs_to :user
  belongs_to :week
  has_many :picks, dependent: :destroy

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
