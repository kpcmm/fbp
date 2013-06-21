require 'net/http'

puts "getting nfl data"

host = 'www.nfl.com'
path = '/schedules/2013/REG1'

count = 0
games = 0
team = {}
Net::HTTP.get(host, path).lines do |line|
  if line =~ /<span class=\"time\">(.+)<\/span>/
    data = Regexp.last_match
    game_time = data[1]
  end

  if line =~ /<span class=\"team-name (home|away) \">([A-Za-z0-9]+)<\/span>/
    count+= 1
    data = Regexp.last_match
    puts "[#{line.strip}] [#{data[1]}: #{data[2]}] #{count}"
    team[data[1]] = data[2]
  end

  if team["home"] && team["away"] && game_time
    games += 1
    puts "=============================== time: #{game_time}, home: #{team["home"]}, away: #{team["away"]}"
    game_time = team["home"] = team["away"] = nil
  end
end

puts "count: #{count}"
puts "games: #{games}"
