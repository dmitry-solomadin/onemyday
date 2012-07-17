class RegistrationsController < ApplicationController
  before_filter :signed_in_user_filter, only: [:edit]

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
      render "registrations/new"
    end
  end

  def edit
    @user = current_user
  end
end
