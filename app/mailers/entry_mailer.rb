class EntryMailer < ActionMailer::Base
  default from: "kpcopley@gmail.com"

  def entry_email(entry)
  	@entry = entry
  	@user = entry.user
  	@picks = @entry.picks.sort { |a,b| a.points <=> b.points }
  	@week = entry.week
  	mail(to: @user.email, subject: "Your FBPhq week #{@week.week_num} entry")
  end
end
