require 'spec_helper'

describe "Special" do
  subject { page }


  describe "signin" do
    before { visit signin_path }

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email",    with: user.email.upcase
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
        it { should_not have_link('Profile') }
      end
    end
  end

end
