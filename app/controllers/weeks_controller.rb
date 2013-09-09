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
		x = (view_context.make_result_image(@week))
		x.each { |line| @status.append line }
		`find . -name 'result*'`.each_line { |line| @status << "find: #{line}"}
		# if @status[-1] == "image done"
		# 	@image_name = "app/assets/images/result_#{@week.week_num}_#{current_user.name}.png"
		# else
		# 	@image_name = "test1.png"
		# end
		@image_name = "images/result_#{@week.week_num}_#{current_user.name}.png"
	end

	def what_if
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
end