require "json"
require 'net/http'

namespace :dbmods do
  desc "move and convert picks to entry details"
  task pick_details: :environment do
    do_pick_details
  end
end

# does not work since Pick model was disassociated from Entry
def do_pick_details
  count = 0
  Entry.all.each do |e|
    count = count + 1
    detail = {}
    e.picks.each do |p|
      g = p.game
      if p.pick == "HOME"
        t = g.home_team
      else
        t = g.away_team
      end
      detail[p.points] = t.code
    end
    d = JSON.generate detail
    puts "count: #{count} details: #{d[0,20]}..."
    e.details =  d
    e.create_picks
    e.save

  end
end

