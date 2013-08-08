require 'spec_helper'

describe Season do
 it "has a valid factory" do
 	expect(FactoryGirl.build(:season)).to be_valid
 end

	it "should not bugger up arithmetic" do
		expect(80 - 1 ).to be(79)
	end

	it "should not bugger up arithmetic part 2" do
		expect(2013 - 13 == 2000).to be_true
	end

  # before do
  #  @season1 = FactoryGirl.create(:season)
  #  @season2 = FactoryGirl.create(:season)
  #  @season2 = FactoryGirl.create(:season)
  #  @season2 = FactoryGirl.create(:season)
  # end
  
  # subject { @season1 }

  # it { should be_valid }
  # # it { should respond_to(:year) }
  # # it { should respond_to(:weeks) }

  # its(:year) { should == 2017 }

  # subject { @season2 }
  # its(:year) { should == 2014 }

  # # subject { @season2 }

  # # its(:year) { should == 2022 }

  # # describe "checking factory operation" do
	 # #  season2 = FactoryGirl.build(:season, year: 2013)
	 # #  season2

  # # end
end
