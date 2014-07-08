class Season < ActiveRecord::Base
  #attr_accessible :year
  validates :year, presence: true,  uniqueness: true

  has_many :weeks, dependent: :destroy

  def get_foy_data

  	players = {}
    weeks.each do |w|
    	next unless w.status == 'PUBLISHED'
    	w.entries.each do |e|
    		next unless e.user.foy
    		name = e.user.name
    		player = players[name]
    		unless player
    			player = {name: name, points: {}, winner: {}, total: 0}
    			players[name] = player
    		end
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
    foy_data
  end
end
