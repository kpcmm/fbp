def game_yml
  File.open(Rails.root.join('test', 'fixtures', "games.yml").to_s, "w") do |f|
    s = Season.find_by_year 2013
    s.weeks.each do |w|
      w.games.each do |g|
        ht = g.home_team
        at = g.away_team
        f.write "game_2011_week#{w.week_num}_#{at.code}_at_#{ht.code}:\n"
        f.write "  status: 'COMPLETE'\n"
        f.write "  week: :week_#{w.week_num}\n"
        f.write "  home_team: :team_#{ht.code}\n"
        f.write "  away_team: :team_#{at.code}\n"
        f.write "  home_points: #{g.home_points}\n"
        f.write "  away_points: #{g.away_points}\n"
        f.write "  start: #{Chronic.parse("728 days ago", :now => g.start)}\n"
        f.write "  tiebreak: #{g.tiebreak}\n"
        f.write "\n"
      end
    end
    s.weeks.each do |w|
      w.games.each do |g|
        ht = g.home_team
        at = g.away_team
        wnum = w.week_num + 17
        f.write "game_2012_week#{w.week_num}_#{at.code}_at_#{ht.code}:\n"
        f.write "  status: 'COMPLETE'\n" if wnum < 24
        f.write "  status: 'NOT_STARTED'\n" if wnum >= 24
        f.write "  week: :week_#{wnum}\n"
        f.write "  home_team: :team_#{ht.code}\n"
        f.write "  away_team: :team_#{at.code}\n"
        f.write "  home_points: #{g.home_points}\n"
        f.write "  away_points: #{g.away_points}\n"
        f.write "  start: #{Chronic.parse("364 days ago", :now => g.start)}\n"
        f.write "  tiebreak: #{g.tiebreak}\n"
        f.write "\n"
      end
    end
  end
  nil
end