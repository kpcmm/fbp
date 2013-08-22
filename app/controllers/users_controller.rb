class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :admin_user,     only: [:index, :destroy]

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def index
      @users = User.paginate(page: params[:page])
  end

  def create
    @user = User.new(params[:user])
    @reg = Reg.find_by_nickname(@user.name.downcase)
    if @reg
      if @user.save
        sign_in @user
        flash[:success] = "Welcome to FBPhq!"
        UserMailer.sign_up_email(@user).deliver
        redirect_to @user
      else
        render 'new'
      end
    else
      flash[:error] = "Participation in this site is by invitation only, please use the name in your invitation email"
      render 'new'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed."
    redirect_to users_url
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      if !current_user.admin?
        flash[:error] = "Not authorized to view users"
        redirect_to(root_path)
      end
    end
end
