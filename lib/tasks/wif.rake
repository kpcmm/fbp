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
  pm = 10
  gm = 10
  tm = 5  # text margin

  ph = 30
  pw = 150

  gh = 100
  gw = 50

  go = pm + pw
  po = gm + gh




  count = 0
  players = []
  Reg.all.each do |r|
    players << r.nickname
  end

  w = Week.find_by_week_num 1
  w.games.each do |g|
    puts g.home_team.display_name
  end



  canvas = Magick::ImageList.new
  canvas.new_image(1000, 3000)

  #r.gravity = Magick::CenterGravity

  # text = Magick::Draw.new
  # text.font_family = 'helvetica'
  # text.pointsize = 9
  # text.gravity = Magick::CenterGravity

  players.each_with_index do |p,i|
    #puts i, p
    r = Magick::Draw.new
    #r.fill = "yellow"
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

    r = Magick::Draw.new
    r.translate go + gw*i + gw/2, po
    r.rotate -60
    r.fill = "black"
    r.text 0,0, "#{g.away_team.display_name}\nat #{g.home_team.display_name}"
    r.draw canvas
  end

  players.each_with_index do |p,i|
    r = Magick::Draw.new
    #puts i, p
    r.fill = "blue"
    r.pointsize = 16
    #r.text(pm+pw/2, po+(i*ph)+(ph/2), p)
    r.text(pm + tm, po + ph*i + ph*0.7, p)
    r.draw canvas

    w.games.each_with_index do |g,j|
      r = Magick::Draw.new
      f = ["red", "blue", "green", "black", "cyan"]
      r.fill = f[(i+j)%5]
      r.pointsize = 20
      r.font_weight = 500
      r.text(go + j*gw + gw*0.2, po + ph*i + ph*0.7, (i%5 + 2*j%7).to_s)
      r.draw canvas
    end
  end


  # players.each_with_index do |p,i|
  #   #puts i, p
  #   text.annotate(canvas, 0, 0, pm+pw/2, po+(i*ph)+(ph/2), p) {
  #      self.fill = 'black'
  #    }
  # end



  #text.fill = "rgb(10%, 50%, 5%)"



  canvas.display

end
