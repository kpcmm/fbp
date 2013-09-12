class EntryMailer < ActionMailer::Base
  default from: "fbpceo@gmail.com"

  def entry_email(entry)
  	@entry = entry
  	@user = entry.user
  	@picks = @entry.picks.sort { |a,b| a.points <=> b.points }
  	@week = entry.week
  	cc = 'kpcmm@yahoo.com' if Rails.env.development?
  	cc = 'kpcmm@yahoo.com' if Rails.env.test?
    cc = 'fbphq@yahoo.com' if Rails.env.production?
    bc = 'fbpceo@gmail.com' if Rails.env.production?
  	mail(to: @user.email, subject: "Your FBPhq week #{@week.week_num} entry", cc: cc)
  end
end
