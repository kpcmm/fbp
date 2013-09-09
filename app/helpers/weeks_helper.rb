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

    Player = Struct.new(:name, :points, :user, :picks, :tb, :cu)

	def make_result_image(week)
		  status = []

		  status << "week num: #{week.week_num}"
		  status << "current user: #{current_user.name}"

		  pm = 30
		  gm = 10
		  tm = 5  # text margin

		  ph = 30
		  pw = 150

		  gh = 100
		  gw = 50

		  tw = 50

		  go = pm + pw + tw
		  po = gm + gh

		  entries = week.entries
		  cu_entry = entries.find_by_user_id current_user.id
		  cu_picks = cu_entry.picks if cu_entry

		  games = week.games.sort { |a,b| a <=> b }
		  games.each do |g|
		  	g.home_points = 0 if g.home_points == nil
		  	g.away_points = 0 if g.away_points == nil
		  end

		  tb_game = week.games.find_by_tiebreak true

		  status << "tiebreak game #{tb_game.away_team.nickname} at #{tb_game.home_team.nickname}"
		  tb_game_points = tb_game.home_points + tb_game.away_points

		  # build an array of player information, so we can later sort it by calculatd total points
		  players = []
		  entries.each do |e|
		  	player = Player.new(e.user.nickname, 0, e.user, [], e.tiebreak, e.user.id == current_user.id)

		  	# build the player picks array and calculate total points for the player
		  	# note it is important that the player picks are ordered the same way as the
		  	# games, since we'll be displaying them with no further reference to the games

		  	games.each do |g|
		  		pick = nil
		  		e.picks.each do |entry_pick|
		  			if entry_pick.game.id == g.id
		  				pick = entry_pick
		  				break
		  			end
		  		end
		  		player.picks << pick
		  		unless g.status == 'NOT_STARTED' 
		  			if g.home_points > g.away_points
		  				if pick.pick == "HOME" then player.points += pick.points end
		  			elsif g.away_points > g.home_points
		  				if pick.pick == "AWAY" then player.points += pick.points end
		  			else
		  				player.points += pick.points / 2.0
		  			end
		  		end
		  	end

		  	players << player
		  end

		  players.sort! do |a,b|
		  	if b.points != a.points
		  		b.points <=> a.points
		    else
			  	adiff = (tb_game_points - a.tb).abs
			  	bdiff = (tb_game_points - b.tb).abs
			  	if bdiff != adiff
			  		adiff <=> bdiff
			  	else
			  		a.tb <=> b.tb
			  	end
		    end

		  end
		  

		  count = 0

		  canvas = Magick::ImageList.new
		  canvas.new_image(1100, 3000)

		  games.each_with_index do |g, i|
		    r = Magick::Draw.new
		    r.stroke = "rgb(80%, 85%, 85%)"
		    r.line go + gw*i, po, go + gw*i, po + entries.size*ph
		    r.draw canvas

		    fill = "gray"
		    pointsize = 10
		    home_ahead = false
		    away_ahead = false
		    unless g.status == "NOT_STARTED"
		      home_ahead = (g.home_points >= g.away_points)
		      away_ahead = (g.home_points <= g.away_points)
		    end

		    cu_pick = cu_picks.find_by_game_id(g.id) if cu_picks

		    r = Magick::Draw.new
		    r.translate go + gw*i + gw/2, po
		    r.rotate -60
		    r.pointsize = 10
		    r.pointsize = 16 if cu_pick and cu_pick.pick == "AWAY"
		    r.fill = "gray"
		    r.fill = "green" if g.status == "NOT_STARTED"
		    r.fill = "red" if away_ahead
		    r.font_weight = 100
		    r.font_weight = 900 if away_ahead
		    r.text 0,0, "#{g.away_team.display_name}"
		    r.draw canvas

		    r = Magick::Draw.new
		    r.translate go + gw*i + gw/2 + gw/3, po
		    r.rotate -60
		    r.pointsize = 10
		    r.pointsize = 16 if cu_pick and cu_pick.pick == "HOME"
		    r.fill = "gray"
		    r.fill = "green" if g.status == "NOT_STARTED"
		    r.fill = "red" if home_ahead
		    r.font_weight = 100
		    r.font_weight = 900 if home_ahead
		    r.text 0,0, "#{g.home_team.display_name}"
		    r.draw canvas
		  end

		  players.each_with_index do |e,i|
		    r = Magick::Draw.new
		    f = ["rgb(90%, 95%, 95%)", "rgb(85%, 90%, 90%)"]
		    r.fill = f[i%2]
		    r.rectangle pm, po + i*ph, go + games.size * gw, po+(i+1)*ph
		    r.draw canvas
		  end

		  players.each_with_index do |player,i|
		    r = Magick::Draw.new
		    r.fill = "rgb(20%, 20%, 20%)"
		    r.pointsize = 16
		    r.text(pm + tm, po + ph*i + ph*0.7, player.name)
		    r.draw canvas

		    total = 0
		    games.each_with_index do |g,j|
		      r = Magick::Draw.new

		      if g.status == "NOT_STARTED"
		        r.fill = "green"
		      else
		        r.fill = "gray"
		        if ((g.home_points >= g.away_points) && player.picks[j] == "HOME") || ((g.away_points >= g.home_points) && player.picks[j] == "AWAY")
		          r.fill = "red"
		        end
		      end

		      r.pointsize = 20
		      wt = [700,100]
		      r.font_weight = wt[(i+j)%2]
		      r.text(go + j*gw + gw*0.2, po + ph*i + ph*0.7, player.picks[j].points.to_s)
		      r.draw canvas
		    end

		    r = Magick::Draw.new
		    r.fill = "blue"
		    r.pointsize = 20
		    r.font_weight = 700
		    r.text(pm + pw + tm, po + ph*i + ph*0.7, player.points.to_s)
		    r.draw canvas
		  end

		  status << "writing image"
		  canvas.write "app/assets/images/result_#{week.week_num}_#{current_user.name}.png"

		  status << "image done"
		  status
	end

end
