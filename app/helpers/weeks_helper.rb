module WeeksHelper
	require 'json'
	require 'net/http'

	def update_scores
		host = 'www.nfl.com'
		path = "/liveupdate/scorestrip/ss.json"

		ss = Net::HTTP.get(host, path)
		parsed = JSON.parse  ss
		# puts ss
		w = parsed["w"]
		year = parsed["y"]

		status = []
		s = Season.find_by_year year
		return status unless s
		status << "got season #{s.year}"

		week = s.weeks.find_by_week_num w
		return status unless week
		status << "got week #{week.week_num}"

		week_type = parsed["t"]
		return status unless week_type == "REG"
		status << "week type #{week_type}"

		#puts "results for ( status#{week_type}) Week #{w} #{year}"
		parsed["gms"].each do |game|
			status << ""
			away_team_code = game["v"]
			home_team_code = game["h"]
			away_team = game["vnn"]
			home_team = game["hnn"]
			disp_code = game["q"]
			disposition = "NOT STARTED" if disp_code == "P"
			disposition = "first quarter" if disp_code == "1"
			disposition = "second quarter" if disp_code == "2"
			disposition = "third quarter" if disp_code == "3"
			disposition = "fourth quarter" if disp_code == "4"
			disposition = "overtime" if disp_code == "5"
			disposition = "Final" if disp_code == "F"
			disposition = "Final overtime" if disp_code == "FO"


			home_score = game["hs"]
			away_score = game["vs"]

			ht = Team.find_by_code home_team_code
			return status unless ht

			status << "home team: #{ht.nickname}"

			g = week.games.find_by_home_team_id ht.id
			return status unless g

			g.status = "NOT STARTED" if disp_code == "P"
			g.status = "STARTED" if disp_code == "1"
			g.status = "STARTED" if disp_code == "2"
			g.status = "STARTED" if disp_code == "3"
			g.status = "STARTED" if disp_code == "4"
			g.status = "STARTED" if disp_code == "5"
			g.status = "COMPLETE" if disp_code == "F"
			g.status = "COMPLETE" if disp_code == "FO"
			status << "game status: #{g.status}"


			g.home_points = home_score.to_i
			g.away_points = away_score.to_i
			status << "home score: #{g.home_points}, away score: #{g.away_points}"

			g.save

			#puts "#{away_team} #{away_score} at  #{home_team} #{home_score}   (#{disposition})"
		end

		status
	end

	require 'RMagick'
	include Magick

    Player = Struct.new(:name, :points, :user, :picks, :tb, :cu, :sort_points)


    def get_games_and_players(week, action, params = nil)
	  entries = week.entries

	  games = week.games.sort_by { |g| "#{g.start.strftime '%Y-%m-%d_%H:%M'}-#{g.home_team.nickname}" }
	  tb_game = nil
	  games.each do |g|
	  	logger.debug "get_games_and_players #{g.away_team.nickname} at #{g.home_team.nickname}"
	  	g.home_points = 0 if g.home_points == nil
	  	g.away_points = 0 if g.away_points == nil
	  	if g.tiebreak 
	  		logger.debug "setting as tiebreak game"
	  		tb_game = g
	  	end
	  end

	  tb_game_points = tb_game.home_points + tb_game.away_points

	  # build an array of player information, so we can later sort it by calculatd total points
	  players = []
	  entries.each do |e|
	  	player = { #Player.new( e.user.nickname, 0, e.user, [], e.tiebreak, e.user.id == current_user.id)
	  		name: e.user.nickname,
	  		points: 0,
	  		user: e.user,
	  		picks: [],
	  		choices: [],
	  		colors: [],
	  		dpoints: [],
	  		tb: e.tiebreak,
	  		cu: e.user.id == current_user.id,
	  		sort_points: 0,
	  		pos: ''
	  		}

	  	logger.debug "get_games_and_players player: #{player[:name]} player tb: #{player[:tb]} entry tb: #{e.tiebreak}, Current user: #{player[:cu]}"

	  	# build the player picks array and calculate total points for the player
	  	# note it is important that the player picks are ordered the same way as the
	  	# games, since we'll be displaying them with no further reference to the games

	  	games.each do |g|
	  		logger.debug "get_games_and_players      game: #{g.away_team.code} at #{g.home_team.code}"
	  		pick = nil
	  		e.picks.each do |entry_pick|
	  			if entry_pick.game.id == g.id
	  				pick = entry_pick
	  				break
	  			end
	  		end
	  		logger.debug "get_games_and_players        pick: #{pick.pick}"
	  		choice = pick.pick
	  		dpoints = pick.points
	  		color = "green"
	  		if g.status != 'NOT_STARTED' && action == :RESULTS
	  			logger.debug "get_games_and_players        game started and RESULTS case"
	  			if g.home_points > g.away_points
	  				if choice == "HOME"
	  					player[:points] += pick.points
	  					color = "red"
	  				else
	  					color = "black"
	  				end
	  			elsif g.away_points > g.home_points
	  				if choice == "AWAY"
	  					player[:points] += pick.points
	  					color = "red"
	  				else
	  					color = "black"
	  				end
	  			else
	  				player[:points] += pick.points / 2.0
	  				dpoints = pick.points / 2.0
	  				color = "red"
	  			end
	  		else
	  			logger.debug "get_games_and_players        game not started or not RESULTS case"
	  			if action == :UPDATE
	  				choice = params["game_#{g.id}"]
	  			end

	  			logger.debug "get_games_and_players        choice: #{choice}"
	  			case choice
	  			when 'NR'
	  				color = "green"
	  			when 'TIE'
	  				player[:points] += pick.points / 2.0	  				
	  				dpoints = pick.points / 2.0
	  				color = "red"
	  			else
		  			if g.home_points >= g.away_points
		  				if choice == "HOME"
		  					player[:points] += pick.points
		  					color = "red"
		  				else
		  					color = "black"
		  				end
		  			elsif g.away_points >= g.home_points
		  				if choice == "AWAY"
		  					player[:points] += pick.points
		  					color = "red"
		  				else
		  					color = "black"
		  				end
		  			else
		  				player[:points] += pick.points / 2.0
		  				dpoints = pick.points / 2.0
		  				color = "red"
		  			end
	  			end
	  		end

	  		player[:picks] << pick
	  		player[:choices] << choice
	  		player[:colors] << color
	  		player[:dpoints] << dpoints
	  	end
	  	logger.debug "choices: #{player[:choices]}"
	  	player[:sort_points] = player[:points]
	  	# add an increment to diffentiate by tiebreak
	  	player[:sort_points] += (1000 -((tb_game_points - player[:tb]).abs)/10000.0)
	  	# add an even smaller increment to differentiate low tiebreak vs high (low wins)
	  	player[:sort_points] += 0.00001 if player[:tb] > tb_game_points 
	  	player[:sort_points] += 0.00002 if player[:tb] < tb_game_points 

	  	players << player
	  end

	  players.sort! { |a,b|  b[:sort_points] <=> a[:sort_points] }

      prev_sort_points = -1
      prev_pos = 0
      results = []
      players.each_with_index do |player,i|
        if player[:sort_points] == prev_sort_points
          player[:pos] = prev_pos
        else
          player[:pos] = i + 1
        end

        prev_sort_points = player[:sort_points]
        prev_pos = player[:pos]
 	  end

	  [games, players]  
    end


end
