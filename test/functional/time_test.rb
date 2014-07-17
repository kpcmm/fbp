require 'test_helper'
require 'chronic'

class TimeTest < ActiveSupport::TestCase
	test "time shifting is working" do
		now = Time.now
	  	travel_to Chronic.parse("two days ago") do
	    	assert_in_delta((now - Time.now), 2*24*60*60, 60, "difference between now and two days ago should be about 2 days worth of seconds")
	  	end
	end
end