require 'net/http'
require 'date'

puts "getting nfl data"

season = 0
week = 0
weeks = 0
count = 0
games = 0
total_games = 0
team = {}
team_code = {}
team_name = {}
File.open("nfl2013.dat", "r") do |f|
  while line = f.gets
    #puts line

    if line =~ /\"[A-Z]+\" : { \"abbr\" : \"([A-Z]+)\", \"url\" : \"(.+)\", \"teamPage\":\"(.+)\", \"city\" : \"(.+)\", \"nickname\" : \"(.+)\", \"conference\": \"(.+)\", \"division\": \"(.+)\", \"shopId\" : \"(.+)\", \"facebook\": \"(.+)\", \"twitter\": \"(.+)\" },/
      data = Regexp.last_match
      puts "found team: #{data[1]} #{data[4]} #{data[5]}"
    end

    if line =~ /nfl data (\d4)/
      data = Regexp.last_match
      season = data[1]
    end

    if line =~ /== week (\d+)/
      data = Regexp.last_match
      weeks += 1
      week = data[1]
      count = 0
      games = 0
      game_time = nil
      time_suffix = nil
      last_date = nil
      puts "== week #{week} =="
    end

    if line =~ /<!-- formattedDate: (.+day), (.+) (.+) -->/
    #if line =~ /<span class=\"\"><span>(.+day), (.+) (.+)<\/span><sup>nd<\/sup><\/span>/
      data = Regexp.last_match
      day_ = data[1]
      month_ = data[2]
      date_ = data[3]
      current_date = "#{month_} #{date_}"
      if current_date != last_date
        puts "------------------- #{current_date} -------------------"
        last_date = current_date
      end
    end

    # #if line =~ /<span class=\"time\">(.+)<\/span>/
    if current_date && line =~/<!-- formattedTime: (\d+:\d+ [AP]M)  -->/
    #if current_date && line =~/formattedTime/
      data = Regexp.last_match
      game_time = data[1]
      #puts "[#{line.strip}] [#{data[1]}]"
      #puts "formatted time #{current_date} #{data[1]}"
      game_date_time = DateTime.strptime("#{current_date} #{game_time} EST", "%B %d %l:%M %P %Z")
      #puts "game date time #{game_date_time}"
    end

    # if game_date_time && line =~ /<span class=\"[ap]m\">([AP]M) <\/span><span class=\"[a-z]+\">([A-Z]+)<\/span>/
    #   data = Regexp.last_match
    #   time_suffix = "#{data[1]} #{data[2]}"
    # end

    if game_date_time && line =~ /<!-- (home|away)Abbr: ([A-Z]+) -->/
      data = Regexp.last_match
      #puts "[#{line.strip}] [#{data[1]}: #{data[2]}] #{count}"
      team_code[data[1]] = data[2]
    end

    if game_date_time && line =~ /<!-- (home|away)Name: ([A-Za-z0-9]+) -->/
      data = Regexp.last_match
      #puts "[#{line.strip}] [#{data[1]}: #{data[2]}] #{count}"
      team_name[data[1]] = data[2]
    end

    if game_date_time && line =~ /<span class=\"team-name (home|away) \">([A-Za-z0-9]+)<\/span>/
      count += 1
      data = Regexp.last_match
      #puts "[#{line.strip}] [#{data[1]}: #{data[2]}] #{count}"
      team[data[1]] = data[2]
    end

    if team["home"] && team["away"] && game_date_time
      games += 1
      puts " time: #{game_date_time}, home: #{team_code["home"]}:#{team_name["home"]}:#{team["home"]}, away: #{team_code["away"]}:#{team_name["away"]}:#{team["away"]}"
      current_date = game_date_time = team["home"] = team["away"] = nil
    end
  end
end


# host = 'www.nfl.com'
# path = '/schedules/2013/REG'
# (1..17).each do |week|
#   wpath = "#{path}#{week}"
#   Net::HTTP.get(host, wpath).lines do |line|
#     puts line
#   end

  #puts "count: #{count}"
  # puts "week #{week}, games: #{games}"
  # puts ""

  # total_games += games
#end

# puts "========================================================"
#   puts "weeks: #{weeks}, total_games: #{total_games}"
