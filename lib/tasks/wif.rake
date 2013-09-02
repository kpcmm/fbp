require 'RMagick'
include Magick

namespace :wif do
  desc "test wif png production"
  task png: :environment do
    make_png
  end
  task clean: :environment do
    make_clean
  end
end

def make_clean
  Reg.all.each do |r|
    r.destroy
  end
  User.all.each do |u|
    u.destroy
  end
end


def make_png
  pm = 30
  gm = 10
  tm = 5  # text margin

  ph = 30
  pw = 150

  gh = 100
  gw = 50

  tw = 50

  go = pm + pw + tw
  po = gm + gh




  count = 0
  players = []
  Reg.all.each do |r|
    players << r.nickname
  end

  status = []
  status << "NOT_STARTED"
  status << "STARTED"
  status << "COMPLETE"
  w = Week.find_by_week_num 1
  w.games.each_with_index do |g, i|
    g.status = status[rand 3]
    if g.status != "NOT_STARTED"
      g.home_points = rand 40
      g.away_points = rand 40
    end
    puts " #{g.status} #{g.away_team.display_name} #{g.away_points} at  #{g.home_team.display_name} #{g.home_points}"
  end

  current_player_picks = ([true]*8 + [false]*8).shuffle

  canvas = Magick::ImageList.new
  canvas.new_image(1100, 3000)

  players.each_with_index do |p,i|


    r = Magick::Draw.new
    f = ["rgb(90%, 95%, 95%)", "rgb(85%, 90%, 90%)"]
    r.fill = f[i%2]
    r.rectangle pm, po + i*ph, go + w.games.size * gw, po+(i+1)*ph
    r.draw canvas
  end


  w.games.each_with_index do |g, i|
    r = Magick::Draw.new
    r.stroke = "rgb(80%, 85%, 85%)"
    r.line go + gw*i, po, go + gw*i, po + players.size*ph
    r.draw canvas

    if g.status == "NOT_STARTED"
    else
    end

    r = Magick::Draw.new
    r.translate go + gw*i + gw/2, po
    r.rotate -60
    r.fill = "gray"
    r.pointsize = 16
    r.font_weight = 900
    r.text 0,0, "#{g.away_team.display_name}"
    r.draw canvas

    r = Magick::Draw.new
    r.translate go + gw*i + gw/2 + gw/3, po
    r.rotate -60
    r.fill = "red"
    r.pointsize = 10
    r.font_weight = 100
    r.text 0,0, "#{g.home_team.display_name}"
    r.draw canvas
  end

  players.each_with_index do |p,i|
    r = Magick::Draw.new
    r.fill = "rgb(20%, 20%, 20%)"
    r.pointsize = 16
    r.text(pm + tm, po + ph*i + ph*0.7, p)
    r.draw canvas

    pick_points = (1..w.games.size).shuffle
    home_picks = ([true]*8 + [false]*8).shuffle
    total = 0
    w.games.each_with_index do |g,j|
      r = Magick::Draw.new

      if g.status == "NOT_STARTED"
      else
      end

      f = ["red", "gray"]
      r.fill = f[(i+j)%2]
      r.pointsize = 20
      wt = [700,100]
      r.font_weight = wt[(i+j)%2]
      points = (i%5 + 2*j%7)
      total += points
      r.text(go + j*gw + gw*0.2, po + ph*i + ph*0.7, pick_points[i].to_s)
      r.draw canvas
    end

    r = Magick::Draw.new
    r.fill = "red"
    r.pointsize = 20
    r.font_weight = 700
    r.text(pm + pw + tm, po + ph*i + ph*0.7, total.to_s)
    r.draw canvas
  end



  canvas.display

end
