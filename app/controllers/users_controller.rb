class UsersController < ApplicationController
  before_filter :signed_in_user_filter, only: [:edit_current, :update, :update_facebook_avatar]

  def new
    @user = User.from_omniauth(session[:omniauth])
  end

  def create
    @user = User.from_omniauth(session[:omniauth])
    @user.email = params[:user][:email]

    if @user.save
      session[:user_id] = @user.id
      redirect_to root_url
    else
      render "users/new"
    end
  end

  def update
    current_user.update_attributes(
        name: params[:user][:name],
        job_title: params[:user][:job_title],
        company: params[:user][:company]
    )

    redirect_to edit_current_user_path
  end

  def show

  end

  def update_avatar_facebook
    current_user.picture_from_url current_user.facebook.get_picture("me") if current_user.facebook
    current_user.save!
    redirect_to edit_current_user_path
  end

  def update_avatar_twitter
    current_user.picture_from_url current_user.twitter.user.profile_image_url if current_user.twitter
    current_user.save!
    redirect_to edit_current_user_path
  end

  def edit_current
    render 'edit'
  end

  def upload_avatar
    current_user.update_attribute(:avatar, params[:file_bean])
    render :nothing => true
  end

end