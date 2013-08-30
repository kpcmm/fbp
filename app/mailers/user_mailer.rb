class UserMailer < ActionMailer::Base
  default from: "fbpceo@gmail.com"

  def sign_up_email(user)
  	@user = user
  	mail(to: user.email, subject: 'Welcome to FBPhq')
  end

  def new_site_email(user)
  	@user = user
  	mail(to: user.email, subject: 'Welcome to FBPhq')
  end
end
