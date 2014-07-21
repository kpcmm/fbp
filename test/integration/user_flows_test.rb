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

    get "weeks/#{weeks(:week_5).id}"
    assert_select "title", "FBP HQ | 2011 week 5"
    assert_select "ol.games" do
    	assert_select "li", 14
    end

    get "users/#{users(:user_101).id}/entries/#{entries(:entry_2011_week4_tgb).id}"
    assert_select "title", "FBP HQ | Valid Entry"
    assert_select "ul.entry_weeks_list li a", 17
    assert_select "div.span7 ul.picklist li", /1 on\s+Tennessee/
    assert_select "div.span7 ul.picklist li", {text: /^1 on/, count: 1}


  end
end
