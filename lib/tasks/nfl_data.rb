require 'net/http'

puts "getting nfl data"

host = 'www.nfl.com'
path = '/schedules/2013/REG'

weeks = 0
total_games = 0
(1..17).each do |week|
  puts "processing week #{week}"
  weeks += 1

  wpath = "#{path}#{week}"
  count = 0
  games = 0
  team = {}
  game_time = nil
  time_suffix = nil
  Net::HTTP.get(host, wpath).lines do |line|
    if line =~ /<span class=\"time\">(.+)<\/span>/
      data = Regexp.last_match
      #puts "[#{line.strip}] [#{data[1]}]"
      game_time = data[1]
    end

    if game_time && line =~ /<span class=\"[ap]m\">([AP]M) <\/span><span class=\"[a-z]+\">([A-Z]+)<\/span>/
      data = Regexp.last_match
      time_suffix = "#{data[1]} #{data[2]}"
    end

    if game_time && line =~ /<span class=\"team-name (home|away) \">([A-Za-z0-9]+)<\/span>/
      count+= 1
      data = Regexp.last_match
      #puts "[#{line.strip}] [#{data[1]}: #{data[2]}] #{count}"
      team[data[1]] = data[2]
    end

    if team["home"] && team["away"] && game_time && time_suffix
      games += 1
      puts " time: #{game_time} #{time_suffix}, home: #{team["home"]}, away: #{team["away"]}"
      game_time = team["home"] = team["away"] = nil
    end
  end

  #puts "count: #{count}"
  puts "week #{week}, games: #{games}"
  puts ""

  total_games += games
end

puts "========================================================"
  puts "weeks: #{weeks}, total_games: #{total_games}"
