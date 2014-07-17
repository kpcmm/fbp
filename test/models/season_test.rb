require 'test_helper'
 
class SeasonTest < ActiveSupport::TestCase
  test "the truth" do
   assert true
  end

  test "year required" do
  	s = Season.new
  	assert_not s.save
  end

  test "no duplicate season" do
  	s = Season.new
  	s.year = 2012
  	assert_not s.save
  end

  test "undefined variable" do
  	assert_raises NameError do
  		xyzplug
  	end
  end
end