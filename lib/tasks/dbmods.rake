require "json"
require 'net/http'

namespace :dbmods do
  desc "move and convert picks to entry details"
  task pick_details: :environment do
    do_pick_details
  end
end

def do_pick_details
  Entry.all.each do |e|
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
    puts d
    e.details =  d
    e,create_picks
    e.save
  end
end

