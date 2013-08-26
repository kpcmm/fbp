require 'net/http'

host = 'www.nfl.com'
path = "/scores/2013/#{ARGV[0]}"

#puts path

in_box = false
in_away = false
in_home = false
away_team = nil
home_team = nil
home_score = nil
away_score = nil
time_left = nil
Net::HTTP.get(host, path).lines do |line|
  #puts line

  if line =~ /<div class=\"new-score-box\">/
    in_box = true
  end

  if in_box && line =~ /<div class=\"away-team\">/
    in_away = true
    in_home = false
  end

  if in_box && line =~ /<div class=\"home-team\">/
    in_home = true
    in_away = false
  end

  if (in_home || in_away) && line =~ /profile\?team=([A-Z]{2,3})/
    data = Regexp.last_match
    if in_home then home_team = data[1] end
    if in_away then away_team = data[1] end
  end

  if (in_home || in_away) && line =~ /<p class=\"total-score\">(\d+)<\/p>/
    data = Regexp.last_match
    score = data[1].to_i
    if in_home then home_score = score end
    if in_away then away_score = score end
  end

  if in_box && line =~ /<p><span class=\"time-left\">(.+)<\/span><\/p>/
    data = Regexp.last_match
    time_left = data[1]
    #puts "time left: #{time_left}"
  end

  if in_box && home_team && away_team && home_score && away_score && time_left
    puts "away: #{away_team} #{away_score}    home: #{home_team} #{home_score}     time_left: #{time_left}"
    in_box = false
    in_away = false
    in_home = false
    away_team = nil
    home_team = nil
    home_score = nil
    away_score = nil
    time_left = nil
  end   
end

puts ""