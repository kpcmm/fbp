buf = [];
File.open("reg2013.dat", "r") do |f|
  while line = f.gets
    buf.push line.split(":")[3]
  end

  buf.sort { |a,b| a.upcase <=> b.upcase }.each do |user|
    puts user
  end
end

