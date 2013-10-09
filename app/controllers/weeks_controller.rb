class WeeksController < ApplicationController
  before_filter :signed_in_user

	def show
		Time.zone= "Pacific Time (US & Canada)"
		@user = current_user
		@week = Week.find(params[:id])
		@games = @week.games.sort { |a,b| a.start <=> b.start }
		@entries = @week.entries
		@entry = Entry.find_by_user_id_and_week_id(current_user.id, @week.id)
		if !@entry
			@entry = @week.entries.create(user_id: current_user.id, tiebreak: 0, status: "NEW"  )
		end
		@picks = @entry.picks
	end

	def result
		@week = Week.find(params[:id])
		view_context.update_scores @week
		@games, @players = view_context.get_games_and_players @week, :NEW
		@user = current_user
		if params[:commit] == 'Publish'
			@week.status = 'PUBLISHED'
			@week.comment = params[:comment]
			@week.save
			@players[0] && @players[0][:entry].winner = true
			@players[0] && @players[0][:entry].save
		end
	end

	def what_if
		logger.info "===================================== W H A T    I F ================================"

		@week = Week.find(params[:id])
		view_context.update_scores @week

		action = :NEW
		action = :UPDATE if params[:commit] == "Update scenario"
		action = :PICKS if params[:commit] == "Use my picks"
		action = :BEST if params[:commit] == "Find my best shot"
		action = :RESET if params[:commit] == "Reset"
		action = :RESULTS if params[:commit] == "Use results"

		@games, @players, @outcomes = view_context.get_games_and_players @week, action, params

	    cutoff = @games[0].start
	    @early = (Time.now <= cutoff)

		@cpi = 0
		@players.each_with_index { |p,i| @cpi = i if p[:cu] }
		logger.debug "cpi: #{@cpi}"
		@user = current_user

	end

	# def foy
	# 	logger.info "===================================== F O Y ================================"

	# 	@week = Week.find(params[:id])
	# 	@status = view_context.update_scores

	# 	action = :NEW
	# 	action = :UPDATE if params[:commit] == "Update scenario"
	# 	action = :PICKS if params[:commit] == "Use my picks"
	# 	action = :BEST if params[:commit] == "Find my best shot"

	# 	@games, @players = view_context.get_games_and_players @week, action, params

	# 	@cpi = nil
	# 	@players.each_with_index { |p,i| @cpi = i if p[:cu] }
	# 	logger.debug "cpi: #{@cpi}"
	# 	@user = current_user

	# end
end