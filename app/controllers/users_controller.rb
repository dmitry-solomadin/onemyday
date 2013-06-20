class UsersController < ApplicationController
  before_filter :signed_in_user_filter, except: [:new, :create, :show]

  def new
    @user = session[:user_to_create] ? session[:user_to_create] : User.new
  end

  def index

  end

  def create
    if session[:omniauth]
      @user = User.from_omniauth(session[:omniauth])
      @user.email = params[:user][:email]
    else
      @user = User.new(params[:user])
    end

    if @user.save
      session[:user_id] = @user.id
      respond_to do |f|
        f.html { redirect_to root_url }
        f.json { render :json => {status: "ok"}.merge(UserFormat.get_hash(@user)) }
      end
    else
      respond_to do |f|
        f.html { render "users/new" }
        f.json { render :json => {errors: @user.errors, status: "bad_request"}.to_json }
      end
    end
  end

  def update
    current_user.update_attributes params[:user]
    current_user.save

    if current_user.valid?
      redirect_to edit_current_user_path
    else
      render 'edit'
    end
  end

  def show
    @user = User.find(params[:id])
    @stories = @user.feed
    respond_to do |f|
      f.html
      f.json { render :json => UserFormat.get_hash(@user) }
    end
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
