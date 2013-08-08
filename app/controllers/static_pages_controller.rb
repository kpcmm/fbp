class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @seasons = Season.all
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
