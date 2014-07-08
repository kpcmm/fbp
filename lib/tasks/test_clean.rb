
def cleanup the_season
  season = Season.find_by_year(the_season)
  if season
    season.weeks.each do |w|
      w.entries.each do |e|
        e.picks.each do |p|
          p.destroy
        end
        e.destroy
      end
      w.games.each do |g|
        g.destroy
      end
    end
    season.destroy
  end
end
