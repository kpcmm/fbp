require 'spec_helper'

describe Week do
  let(:season) { FactoryGirl.create(:season) }
  before { @week = season.weeks.build(num_games: 15, tiebreak_game_id: 592, week_num: 32) }
  
  subject { @week }

  it { should be_valid }
end
