require "json"
require 'net/http'

namespace :nfl do
  desc "Fill database with real data"
  task populate: :environment do
    get_data
    make_games_and_teams
  end
  task clean: :environment do
    cleanup
  end
end

def cleanup
  Pick.all.each do |p|
    p.destroy
  end
  Entry.all.each do |e|
    e.destroy
  end
  Game.all.each do |g|
    g.destroy
  end
  Week.all.each do |w|
    w.destroy
  end
  Team.all.each do |t|
    t.destroy
  end
  Season.all.each do |s|
    s.destroy
  end
end

def get_data
  host = 'www.nfl.com'
  nflraw = File.open(Rails.root.join('lib', 'tasks', 'nfl2014raw.dat').to_s, "w")

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

  schedule = {}
  schedule[:season] = 2014
  schedule[:weeks] = []
  (1..num_weeks).each do |w|
    path = "/schedules/2014/REG#{w}"
    game_data = {}
    week = {}
    week[:week] = w
    week[:games] = []
    schedule[:weeks].append week
    Net::HTTP.get(host, path).lines do |line|
      nflraw.write line
      if line =~ /^<!-- ([A-Za-z]+): (.+) -->/
        data = Regexp.last_match
        tag = data[1]
        value = data[2]
        game_data[tag] = value if tags.include? tag
        week[:games].append game_data if tag == last_tag
      end

    end
  end

  nflraw.close
  File.open(Rails.root.join('lib', 'tasks', 'nfl2014.json').to_s, "w") do |outfile|
    outfile.write(JSON.pretty_generate schedule)
  end
end

def ensure_team(params)
  display_name = params[:city]
  display_name = 'N.Y. Giants' if params[:code] == 'NYG'
  display_name = 'N.Y. Jets' if params[:code] == 'NYJ'
  nickname = params[:name]
  team = Team.find_by_code(params["code"])
  if !team
    Team.create(code: params[:code], nickname: nickname, city: params[:city], name: "#{params[:city]} #{nickname}", display_name: display_name )
  end
end

def make_games_and_teams
  season = Season.find_by_year(2014)
  if !season
    season = Season.create(year: 2014)
  end
  nfljson = File.open(Rails.root.join('lib', 'tasks', 'nfl2014.json').to_s, "r")
  total_games = 0;
  last_date = nil
  pdata = JSON.load nfljson
  pdata["weeks"].each do |w|
    week = Week.find_by_season_id_and_week_num(season.id, w["week"])
    if !week
      week = season.weeks.create(week_num: w["week"], status: "NOT_STARTED")
    end
    games = w["games"]
    total_games += games.size
    games.each do |g|
      ensure_team({code: g["homeAbbr"], city: g["homeCityName"], name: g["homeName"]})
      ensure_team({code: g["awayAbbr"], city: g["awayCityName"], name: g["awayName"]})

      g["formattedDate"] =~ /(.+day), (.+) (.+)/
      data = Regexp.last_match
      day_ = data[1]
      month_ = data[2]
      date_ = data[3]
      current_date = "#{month_} #{date_}"

      g["formattedTime"] =~ /(\d+:\d+ [AP]M)/
      data = Regexp.last_match
      game_time = data[1]
      game_date_time = Time.zone.parse("#{season.year} #{current_date} #{game_time}")

      home_team = Team.find_by_code(g["homeAbbr"])
      away_team = Team.find_by_code(g["awayAbbr"])
      week.games.create!(home_team_id: home_team.id, away_team_id: away_team.id, status: 'NOT_STARTED', start: game_date_time, tiebreak: false)
    end
  end
end

