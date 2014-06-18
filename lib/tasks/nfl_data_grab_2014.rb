require 'net/http'
require "set"

puts "getting nfl data"
host = 'www.nfl.com'
nflraw = File.open("nfl2014raw.dat", "w")
nfljson = File.open("nfl2014.json", "w")

tags = Set.new()
tags.add "formattedDate"
tags.add "formattedTime"
tags.add "awayAbbr"
tags.add "homeAbbr"
tags.add "awayName"
tags.add "homeName"
tags.add "awayCityName"
tags.add "homeCityName"

last_tag = "homeCityName"

num_weeks = 17

nfljson.write "{\n"
nfljson.write "    \"season\": 2014,\n"
nfljson.write "    \"weeks\": [\n"
(1..num_weeks).each do |week|
  path = "/schedules/2014/REG#{week}"
  nfljson.write "        {\n"
  nfljson.write "            \"week\": #{week},\n"
  nfljson.write "            \"games\": ["
  count = 0
  games = 0
  team = {}
  game_data = {}
  first_game = true
  Net::HTTP.get(host, path).lines do |line|
    nflraw.write line
    if line =~ /^<!-- ([A-Za-z]+): (.+) -->/
      data = Regexp.last_match
      tag = data[1]
      value = data[2]
      game_data[tag] = value

      if tag == last_tag
        first_tag = true
        temp_str = ""
        if first_game
          nfljson.write "\n                {"
        else
          nfljson.write ",\n                {"
        end
        first_game = false
        tags.each do |t|
          if first_tag
            nfljson.write "\n"
          else
            nfljson.write ",\n"
          end
          nfljson.write "                    \"#{t}\": \"#{game_data[t]}\""
          first_tag = false
        end
        nfljson.write "\n                }"
      end
    end

  end
  nfljson.write "\n            ]\n"
  nfljson.write "        }"
  nfljson.write "," if week != num_weeks
  nfljson.write "\n"

end

nflraw.close
nfljson.write "    ]\n}\n"
nfljson.close
