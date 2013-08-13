class SeasonsController < ApplicationController
	def index
		@seasons = Season.all
	end

	def show
		Time.zone= "Eastern Time (US & Canada)"
	    @season = Season.find(params[:id])
	    @weeks = @season.weeks. sort { |a,b| a.week_num <=> b.week_num }
	    @cutoff = []
	    @weeks.each do |w|
	    	games = w.games.sort { |a,b| a.start <=> b.start }
	    	@cutoff[w.week_num] = games[0].start
	    end
	end
end
