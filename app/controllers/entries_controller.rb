class EntriesController < ApplicationController
  before_filter :signed_in_user
  before_filter :correct_user, only: [:edit, :update, :destroy]

  def new
  end

  def show
    setup
    @picks = @picks.sort { |a, b| a.points <=> b.points }
  end

  def edit
    @entry = Entry.find(params[:id])
    @user = current_user
    @week = @entry.week
    @games = @week.games
    Time.zone= "Eastern Time (US & Canada)"

    if !@entry.picks.any?
      @games.each do |g|
        @entry.picks.create(entry_id: @entry.id, game_id: g.id, pick: "NONE")
      end
    end
    @picks = @entry.picks.sort { |a, b| a.game.start == b.game.start ? a.game.home_team.name <=> b.game.home_team.name : a.game.start <=> b.game.start }
  end
  
  def update
    flash.clear
    Time.zone= "Eastern Time (US & Canada)"
    @entry = Entry.find(params[:id])
    @week = @entry.week
    @games = @week.games.sort { |a,b| a <=> b }
    n = @games.size

    cutoff = @games[0].start
    if Time.now > cutoff
      flash.now[:alert] = " Sorry, cutoff time for week #{@week.week_num} has passed"
      render 'show' and return
    end

    @user = current_user

    usage = Array.new(n+1, 0)
    problems = []

    @picks = @entry.picks.sort { |a, b| a.game.start <=> b.game.start }
    @picks.each do |pick|
      home_points = params[pick.game.home_team.code].to_i
      away_points = params[pick.game.away_team.code].to_i
      if home_points > 0 && home_points <= n && away_points == 0
          pick.points = home_points
          usage[home_points] += 1
          pick.pick = "HOME"
      elsif away_points > 0 && away_points <= n && home_points == 0
          pick.points = away_points
          usage[away_points] += 1
          pick.pick = "AWAY"
      else
        pick.points = 0
        pick.pick = 'NONE'
        problems << "No valid pick for #{pick.game.away_team.name} at #{pick.game.home_team.name}"
      end
      pick.save
    end

    tb = params['tiebreak']
    if tb.strip.length == 0 || tb.to_i < 0
      problems << 'Tiebreak is missing'
      @entry.tiebreak = nil
    else
      @entry.tiebreak = tb.to_i
    end

    @entry.save

    problems.each do |p|
      @entry.errors[:base] << p
    end

    (1..n).each do |x|
      if usage[x] == 0
        @entry.errors[:base] << "Number #{x} not used"
      elsif usage[x] == 2
        @entry.errors[:base] << "Number #{x} used twice"
      elsif usage[x] > 2
        @entry.errors[:base] << "Number #{x} used #{usage[x]} times"
      end
    end

    if @entry.errors.any?
      render 'edit'
    else
      flash.now[:success] = "Congratulations! Your week #{@week.week_num} picks are good!"
      @picks = @picks.sort { |a, b| a.points <=> b.points }
      render 'show'
    end

  end

  def create
  end

  def destroy
    @entry.destroy
    redirect_to root_url
  end

  private
    def setup
      @entry = Entry.find(params[:id])
      @user = current_user
      @week = @entry.week
      @games = @week.games
      Time.zone= "Eastern Time (US & Canada)"

      if !@entry.picks.any?
        @games.each do |g|
          @entry.picks.create(entry_id: @entry.id, game_id: g.id, pick: "NONE")
        end
      end
      @picks = @entry.picks.sort { |a, b| a.game.start <=> b.game.start }
    end

    def correct_user
     entry = Entry.find(params[:id])
     if entry.user_id != current_user.id
      flash[:error] = "You cannot work with other peoples' entries"
      redirect_to root_url
     end
    end
end
