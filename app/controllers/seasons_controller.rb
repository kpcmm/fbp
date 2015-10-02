class SeasonsController < ApplicationController
  before_filter :signed_in_user
  before_filter :admin_user?, only: [:agreements]

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
	    @user = current_user
	end

	def foy
		Time.zone= "Pacific Time (US & Canada)"
	    @season = Season.find(params[:id])
	    @foy_data = @season.get_foy_data
	    logger.debug "foy_data #{@foy_data}"
	end

	def agreements
	    @season = Season.find(params[:id])
	    @people = []
	    users = User.all
	    users.sort {|a,b| a.name <=> b.name}.each do |u|
	    	person = {}
	    	person[:id] = u.id
	    	person[:name] = u.name
	    	person[:email] = u.email
	    	a = u.agreements.find_by_season_id @season.id
	    	if a
	    		person[:foy] = a.foy
	    		person[:paid] = a.paid
	    		person[:agreement] = a.id
	    	else
	    		person[:foy] = false
	    		person[:paid] = false
	    		person[:agreement] = nil
	    	end
	    	@people << person
	    end
	end

	def update_agreements
		Time.zone= "Pacific Time (US & Canada)"
	    @season = Season.find(params[:id])

	    User.all.each do |user|
   			a = user.agreements.find_by_season_id @season.id
	    	playing = false
	    	if params[:people] && (p = params[:people][user.id.to_s])
	    		if p["playing"] == "y"
	    			playing = true
	    			a = Agreement.new(user_id: user.id, season_id: @season.id) if !a
	    			a.foy = (p[:foy] == "y")
	    			a.paid = (p[:paid] == "y")
	    			a.save
	    		else
    				a.destroy if a
	    		end
	    	else
   				a.destroy if a
	    	end
	    end

	    redirect_to agreements_season_path(@season), notice: "Agreements updated successfully #{Time.now.strftime("%d/%m/%Y %H:%M:%S")}"
	end
end
