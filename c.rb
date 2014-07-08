
class Entry
  def do_picks
    @picks = []
    week.games.each do |g|
      @picks.append P.new g
    end
    puts "made picks #{@picks}"
    if details
      (JSON.parse details).each do |points,code|
      	puts "looking at #{points} => #{code}"
        team = Team.find_by_code code
        puts "found team #{team.name}"
        game = Game.find_by_home_team_id_and_week_id team.id, week.id
        game = Game.find_by_away_team_id_and_week_id team.id, week.id if !game
        puts "found game #{game}"
        @picks.each do |p|
          if p.game.id == game.id
            p.points = points
            p.pick = "HOME" if code == game.home_team.code
            p.pick = "AWAY" if code == game.away_team.code
          end
        end
      end
    end
    @picks
  end
end

e = Entry.first
e.do_picks
