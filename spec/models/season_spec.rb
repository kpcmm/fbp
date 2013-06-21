require 'spec_helper'

describe Season do
  before do
    @season = Season.new(year: 1900)
  end
  
  subject { @season }

  it { should respond_to(:year) }
end
