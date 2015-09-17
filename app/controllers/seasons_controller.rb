class SeasonsController < ApplicationController
  before_filter :signed_in_user

	def index
		@seasons = Season.all
	end

	def show
		Time.zone= "Pacific Time (US & Canada)"
	    @season = Season.find(params[:id])
	    current_season = @season if @season
	    @weeks = @season.weeks. sort { |a,b| a.week_num <=> b.week_num }
	    @cutoff = []
	    @weeks.each do |w|
	    	games = w.games.sort { |a,b| a.start <=> b.start }
	    	@cutoff[w.week_num] = games[0].start
	    end
	end

	def foy
		Time.zone= "Pacific Time (US & Canada)"
	    @season = Season.find(params[:id])
	    @foy_data = @season.get_foy_data
	    logger.debug "foy_data #{@foy_data}"
	end
end
