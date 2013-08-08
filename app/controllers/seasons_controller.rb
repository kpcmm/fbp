class SeasonsController < ApplicationController
	def index
		@seasons = Season.all
	end

	def show
	    @season = Season.find(params[:id])
	    @weeks = @season.weeks
	end
end
