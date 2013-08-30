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