require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
  test "login and out not as admin" do
	get "/"
	assert_select "h1", 1, "Should be exactly one <h1> section"
	assert_select "title", {:text => "FBP HQ"}, "title should be FBP HQ"
    assert_select "h1", "Welcome to FBPhq"
    assert_select "a.btn", 1
	assert_response :success
 
    # login via https
    https!
    get "/signin"
    assert_response :success
 
    post_via_redirect "/sessions", {name: users(:user_101).name, password: 'foobar'}
    assert_equal '/', path
    assert_select "ul.seasons" do
    	assert_select "li", 2
    end

    get_via_redirect "/users"
    assert_select "title", "FBP HQ"
    assert_select "div div.alert", "Not authorized to view users"

    get "/seasons"
    assert_select "title", "FBP HQ | All Seasons"
    #assert_select "body>div>h1", "Sign in"
    assert_response :success
  end

  test "check user cannot access seasons unless signed in" do
    get "/seasons"
    #assert_select "title", "FBP HQ"
    #assert_select "body>div>h1", "Sign in"
    assert_response :redirect

    get_via_redirect "/seasons"
    #assert_select "title", "FBP HQ"
    assert_select "h1", "Sign in"
  end

end

