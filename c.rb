def entry_yml
  File.open(Rails.root.join('test', 'fixtures', "entries.yml").to_s, "w") do |f|
    s = Season.find_by_year 2013
    s.weeks.each do |w|
      w.entries.each do |e|
        u = e.user
        f.write "entry_#{s.year}_week#{w.week_num}_#{u.name.sub(' ', '_')}:\n"
        f.write "  user: :user_#{u.id}\n"
        f.write "  week: :week_#{w.week_num}\n"
        f.write "  status: '#{e.status}'\n"
        f.write "  tiebreak: '#{e.tiebreak}'\n"
        f.write "  details: '#{e.details}'\n"
        f.write "\n"
      end
    end
  end
  nil
end
