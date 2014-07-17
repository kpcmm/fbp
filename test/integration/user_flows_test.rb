require 'test_helper'

class UserFlowsTest < ActionDispatch::IntegrationTest
test "login and browse site" do
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

    get "/seasons/#{seasons(:year_one).id}"
    assert_select "title", "FBP HQ | FBP Season 2011"
    assert_select "ul.weeks" do
    	assert_select "li", 17
    end
    # assert_select "script", 200

    # assert_equal 'Welcome david!', flash[:notice]
 
    # https!(false)
    # get "/posts/all"
    # assert_response :success
    # assert assigns(:products)
  end
end
