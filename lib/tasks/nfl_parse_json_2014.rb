require 'net/http'
require 'date'
require "json"

puts "getting nfl data"

nfljson = File.open("nfl2014.json", "r")
total_games = 0;
pdata = JSON.load nfljson
pdata["weeks"].each do |w|
  games = w["games"]
  puts "json week #{w["week"]}, games: #{games.size}"
  total_games += games.size
  games.each do |g|
    puts "#{g["awayName"]} at #{g["homeName"]}"
  end
end

puts "total_games #{total_games}"

