def user_yml
  File.open(Rails.root.join('test', 'fixtures', "users.yml").to_s, "w") do |f|
    User.all.each do |u|
      f.write "user_#{u.id}:\n"
      f.write "  name: '#{u.name}'\n"
      f.write "  email: '#{u.email}'\n"
      f.write "  password_digest: '#{u.password_digest}'\n"
      f.write "  remember_token: '#{u.remember_token}'\n"
      f.write "  admin: #{u.admin}\n"
      f.write "  foy: #{u.foy}\n"
      f.write "  nickname: '#{u.nickname}'\n"
      f.write "\n"
    end
  end
  nil
end