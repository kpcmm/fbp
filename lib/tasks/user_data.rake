namespace :user do
  desc "Fill database with sample data"
  task populate: :environment do
    make_reg
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

def make_reg
  count = 0;
  File.open(Rails.root.join('lib', 'tasks', 'reg2013.dat').to_s, "r") do |r|
    while line = r.gets
      parts = line.split ":"
      Reg.create(name: parts[1], email: parts[2], nickname: parts[3].downcase, admin: parts[4])
    end
  end
end
