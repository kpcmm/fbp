module WeeksHelper
	require 'json'
	require 'net/http'


	def update_scores(week)
		return if week.status == 'COMPLETE' or week.status == 'PUBLISHED'
		#host = 'www.nfl.com'
		host = '50.174.118.222'
		path = "/liveupdate/scorestrip/ss.json"

		uri = URI('50.174.118.222:8080/cgi/nfl.py')
		#ss = Net::HTTP.get(host, path)
		ss = Net::HTTP.get(uri)
		parsed = JSON.parse  ss
		# puts ss
		w = parsed["w"]
		year = parsed["y"]

		status = []
		s = Season.find_by_year year
		return status unless s
		status << "got season #{s.year}"

		#note: this might be a different week than we came in with
		week = s.weeks.find_by_week_num w
		return status unless week
		status << "got week #{week.week_num}"
		return if week.status == 'COMPLETE' or week.status == 'PUBLISHED'

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
			n = false # seen not started game
			s = false # seen started game
			c = false # seen complete game
			week.games.each do |g|
				n = true if g.status == 'NOT_STARTED'
				s = true if g.status == 'STARTED'
				c = true if g.status == 'COMPLETE'
			end

			if c && !s && !n
				week.status = 'COMPLETE'
			elsif s
				week.status = 'STARTED'
			else
				week.status = 'NOT_STARTED'
			end
		
			week.save
			
			#puts "#{away_team} #{away_score} at  #{home_team} #{home_score}   (#{disposition})"
		end

		status
	end


    Player = Struct.new(:name, :points, :user, :picks, :tb, :cu, :sort_points)


    def get_games_and_players(week, action, params = nil)
	  entries = week.entries

	  games = week.games.sort_by { |g| "#{g.start.strftime '%Y-%m-%d_%H:%M'}-#{g.home_team.nickname}" }
	  tb_game = nil

	  cue = entries.first
	  entries.each do |e|
	  	if e.user_id == current_user.id
	  		cue = e
	  		break
	  	end
	  end

	  outcomes = []
	  games.each do |g|
	  	logger.debug "get_games_and_players #{g.away_team.nickname} at #{g.home_team.nickname} (#{g.away_team.code} at #{g.home_team.code})"
	  	g.home_points = 0 if g.home_points == nil
	  	g.away_points = 0 if g.away_points == nil
	  	if g.tiebreak 
	  		logger.debug "setting as tiebreak game"
	  		tb_game = g
	  	end

  		cu_pick = nil
  		cue.picks.each do |cup|
  			if cup.game.id == g.id
  				cu_pick = cup
  				break
  			end
  		end

  		logger.debug "get_games_and_players        action: #{action}"
  		case action
  		when :RESET
  			outcome = 'NR'
  		when :BEST
  			outcome = 'NR'
  		when :UPDATE
  			outcome = params["game_#{g.id}"]
  		when :PICKS
  			outcome = 'NR'
  			outcome = cu_pick.pick if cu_pick
  		when :RESULTS, :NEW
  			if g.status == 'NOT_STARTED'
  				outcome = 'NR'
	  			outcome = params["game_#{g.id}"] if params && params["game_#{g.id}"]
  			else
	  			outcome = 'HOME' if g.home_points > g.away_points
	  			outcome = 'AWAY' if g.away_points > g.home_points
	  			outcome = 'TIE' if g.away_points == g.home_points
  			end
  		else
  			outcome = 'NR'
  		end

  		home_color = away_color = "green" #default
  		case outcome
  		when 'NR'
  		when 'TIE'
  			home_color = away_color = "red"
  		when 'HOME'
  			home_color = "red"
  			away_color = "black"
  		when 'AWAY'
  			home_color = "black"
  			away_color = "red"
  		end
  		outcomes << {game: g, home_color: home_color, away_color: away_color, outcome: outcome}
	  end

	  tb_game_points = tb_game ? tb_game.home_points + tb_game.away_points : 0

	  # build an array of player information, so we can later sort it by calculatd total points
	  players = []
	  entries.each do |e|
	  	next unless e.picks.size == week.games.size && e.tiebreak && e.tiebreak > 0
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
	  		pos: '',
	  		entry: e
	  		}

	  	logger.debug "get_games_and_players player: #{player[:name]} player tb: #{player[:tb]} entry tb: #{e.tiebreak}, Current user: #{player[:cu]}"

	  	# build the player picks array and calculate total points for the player
	  	# note it is important that the player picks are ordered the same way as the
	  	# games, since we'll be displaying them with no further reference to the games

	  	#games.each do |g|
	  	outcomes.each do |o|
	  		g = o[:game]
	  		outcome = o[:outcome]
	  		logger.debug "get_games_and_players      game: #{g.away_team.code} at #{g.home_team.code}"
	  		pick = nil
	  		e.picks.each do |entry_pick|
	  			if entry_pick.game.id == g.id
	  				pick = entry_pick
	  				break
	  			end
	  		end

	  		dpoints = 0
	  		color = "blue"
	  		logger.debug "get_games_and_players        outcome: #{outcome}"
	  		case outcome
	  		when 'NR'
	  			dpoints = pick.points
				color = "green"
	  		when 'TIE'
	  			dpoints = pick.points/2.0
				player[:points] += dpoints
				color = "red"
			else
				if pick.pick == outcome
		  			dpoints = pick.points.to_i
					player[:points] += dpoints
  					color = "red"
				else
		  			dpoints = pick.points
  					color = "black"
  				end
	  		end

	  		#player[:picks] << pick
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

	  [games, players, outcomes]  
    end

    def gen_foy_data
    	Week.all.sort_by_week_num do |w|
    		logger.debug "gen_foy_data #{w.week_num}"
    	end
    end
end
