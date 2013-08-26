require 'json'
require 'net/http'

host = 'www.nfl.com'
path = "/liveupdate/scorestrip/ss.json"

ss = Net::HTTP.get(host, path)
parsed = JSON.parse  ss
# puts ss
week = parsed["w"]
year = parsed["y"]
week_type = parsed["t"]
puts "results for (#{week_type}) Week #{week} #{year}"
parsed["gms"].each do |game|
	away_team_code = game["v"]
	home_team_code = game["h"]
	away_team = game["vnn"]
	home_team = game["hnn"]
	disp_code = game["q"]
	disposition = "Not started" if disp_code == "P"
	disposition = "first quarter" if disp_code == "1"
	disposition = "second quarter" if disp_code == "2"
	disposition = "third quarter" if disp_code == "3"
	disposition = "fourth quarter" if disp_code == "4"
	disposition = "overtime" if disp_code == "5"
	disposition = "Final" if disp_code == "F"
	disposition = "Final overtime" if disp_code == "FO"
	home_score = game["hs"]
	away_score = game["vs"]
	puts "#{away_team} #{away_score} at  #{home_team} #{home_score}   (#{disposition})"
end
