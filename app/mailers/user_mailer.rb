class UserMailer < ActionMailer::Base
  default from: "kpcopley@gmail.com"

  def sign_up_email(user)
  	@user = user
  	mail(to: user.email, subject: 'Welcome to FBPhq')
  end
end
