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
		@status = []
		#@status = view_context.update_scores
		#@results,x,@image_name = (view_context.make_result_image(@week))
		#@players, @games = (view_context.make_result_image(@week))
		@games, @players = view_context.get_games_and_players @week, :NEW
		# @status = []
		# @status << "pick count #{@players[0].picks.size}"
		# @players[0].picks.each do |pp|
		# 	@status << "pick  #{pp.pick} #{pp.points}"
		# end
		#@status = []
		#x.each { |line| @status.append line }
		#{}`find . -name 'result*'`.each_line { |line| @status << "find: #{line}"}
		# if @status[-1] == "image done"
		# 	@image_name = "app/assets/images/result_#{@week.week_num}_#{current_user.name}.png"
		# else
		# 	@image_name = "test1.png"
		# end
		#@image_name = "result_#{@week.week_num}_#{current_user.name}.png"
	end

	def what_if
		logger.info "===================================== W H A T    I F ================================"

		@week = Week.find(params[:id])
		@status = view_context.update_scores

		action = :NEW
		action = :UPDATE if params[:commit] == "Update scenario"
		action = :PICKS if params[:commit] == "Use my picks"
		action = :BEST if params[:commit] == "Find my best shot"

		@games, @players = view_context.get_games_and_players @week, action, params

		@cpi = nil
		@players.each_with_index { |p,i| @cpi = i if p[:cu] }
		logger.debug "cpi: #{@cpi}"
		@user = current_user

	end

	def foy
		logger.info "===================================== F O Y ================================"

		@week = Week.find(params[:id])
		@status = view_context.update_scores

		action = :NEW
		action = :UPDATE if params[:commit] == "Update scenario"
		action = :PICKS if params[:commit] == "Use my picks"
		action = :RESULTS if params[:commit] == "Use results"
		action = :BEST if params[:commit] == "Find my best shot"

		@games, @players = view_context.get_games_and_players @week, action, params

		@cpi = nil
		@players.each_with_index { |p,i| @cpi = i if p[:cu] }
		logger.debug "cpi: #{@cpi}"
		@user = current_user

	end
end