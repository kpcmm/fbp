namespace :nfl do
  desc "Fill database with sample data"
  task populate: :environment do
    make_teams
    make_games
  end
  task clean: :environment do
    make_clean
  end
end

def make_clean
  Season.all.each do |s|
    s.destroy
  end
  Team.all.each do |t|
    t.destroy
  end
end

def make_teams
  count = 0;
  File.open(Rails.root.join('lib', 'tasks', 'nfl2013.dat').to_s, "r") do |f|
    while line = f.gets
      if line =~ /\"[A-Z]+\" : { \"abbr\" : \"([A-Z]+)\", \"url\" : \"(.+)\", \"teamPage\":\"(.+)\", \"city\" : \"(.+)\", \"nickname\" : \"(.+)\", \"conference\": \"(.+)\", \"division\": \"(.+)\", \"shopId\" : \"(.+)\", \"facebook\": \"(.+)\", \"twitter\": \"(.+)\" }/
        data = Regexp.last_match
        code = data[1]
        city = data[4]
        display_name = city
        display_name = 'N.Y. Giants' if code == 'NYG'
        display_name = 'N.Y. Jets' if code == 'NYJ'
        nickname = data[5]
        team = Team.find_by_code(code)
        if !team
          #puts "team: #{code} #{city} #{nickname}"
          count += 1
          Team.create(code: code, nickname: nickname, city: city, name: "#{city} #{nickname}", display_name: display_name )
          #puts "count #{count}"
        end
      end

      if count > 25 && line =~ /<\/script>/
        break
      end
    end
  end
end

def make_games
  year = 0
  season = nil
  week_num = 0
  week = nil
  weeks = 0
  count = 0
  games = 0
  game = nil
  home_team = nil
  away_team = nil
  total_games = 0
  team = {}
  team_code = {}
  team_name = {}
  Time.zone= "Eastern Time (US & Canada)"
  File.open(Rails.root.join('lib', 'tasks', 'nfl2013.dat').to_s, "r") do |f|
    while line = f.gets
      if line =~ /nfl data (\d{4})/
        data = Regexp.last_match
        year = data[1]
        puts "got season, year: #{year}"
        season = Season.find_by_year(year)
        if !season
          season = Season.create(year: year)
        end
      end

      if line =~ /== week (\d+)/
        data = Regexp.last_match
        weeks += 1
        week_num = data[1]
        puts "------------------- week #{week_num} -------------------"
        count = 0
        games = 0
        game_time = nil
        time_suffix = nil
        last_date = nil
        week = Week.find_by_season_id_and_week_num(season.id, week_num)
        if !week
          week = season.weeks.create(week_num: week_num, status: "NOT_STARTED")
        end
      end

      if line =~ /<!-- formattedDate: (.+day), (.+) (.+) -->/
        data = Regexp.last_match
        day_ = data[1]
        month_ = data[2]
        date_ = data[3]
        current_date = "#{month_} #{date_}"
        if current_date != last_date
          puts "--#{current_date} -------------------"
          last_date = current_date
        end
      end

      if current_date && line =~/<!-- formattedTime: (\d+:\d+ [AP]M)  -->/
        data = Regexp.last_match
        game_time = data[1]
        game_date_time = Time.zone.parse("#{season.year} #{current_date} #{game_time}")
        #puts("#{season.year} #{current_date} #{game_time} =>>>  #{game_date_time}")
      end

      if game_date_time && line =~ /<!-- (home|away)Abbr: ([A-Z]+) -->/
        data = Regexp.last_match
        team_code[data[1]] = data[2]
        #puts "--#{data[1]} #{data[2]} -------------------"
      end

      if team_code["home"] && team_code["away"] && game_date_time
        games += 1
        puts " time: #{game_date_time}, home: #{team_code["home"]}, away: #{team_code["away"]}"
        home_team = Team.find_by_code(team_code["home"])
        away_team = Team.find_by_code(team_code["away"])
        week.games.create!(home_team_id: home_team.id, away_team_id: away_team.id, status: 'NOT_STARTED', start: game_date_time, tiebreak: false)
        current_date = game_date_time = team_code["home"] = team_code["away"] = nil
      end
    end
  end
  season.weeks.each {|w| g=w.games.last;  g.tiebreak = true;  g.save}
end
