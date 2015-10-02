class Season < ActiveRecord::Base
  #attr_accessible :year
  validates :year, presence: true,  uniqueness: true

  has_many :weeks, dependent: :destroy
  has_many :agreements
  has_many :users, through: :agreements

  def get_foy_data

  	players = {}
    agreements.each do |a|
      next unless a.foy
      player = {name: a.user.name, points: {}, winner: {}, total: 0}
      players[a.user.name] = player      
    end

    complete = true
    weeks.each do |w|
      complete = false unless w.status == 'PUBLISHED'
    	next unless w.status == 'PUBLISHED'
    	w.entries.each do |e|
        next unless (player = players[e.user.name])
    		# next unless ((u = users.find_by_id e.user.id) && ((a = u.agreements.find_by_season_id id) && a.foy))
    		# name = e.user.name
    		# player = players[name]
    		# unless player
    		# 	player = {name: name, points: {}, winner: {}, total: 0}
    		# 	players[name] = player
    		# end
    		points = e.get_points
    		player[:points][w.week_num] = points
    		player[:winner][w.week_num] = e.winner
    		player[:total] += points
    	end
    end
    pa = []
    players.each { |p| pa << p[1] }
    pa.sort! { |a,b| b[:total] <=> a[:total] }

  	foy_data = {}
  	foy_data[:players] = pa
  	foy_data[:max_week] = weeks.count
    foy_data[:complete] = complete

    foy_data
  end
end
