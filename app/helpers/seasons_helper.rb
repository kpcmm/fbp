module SeasonsHelper
	def current_season
		@current_season ||= Season.find_by_year(cookies[:the_season])
	end
	def current_season=(s)
	    cookies.permanent[:the_season] = s.year
		@current_season = s
	end
end
