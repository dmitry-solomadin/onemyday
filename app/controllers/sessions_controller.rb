class SessionsController < ApplicationController

  before_filter :signed_in_user_filter, only: [:destroy_auth]

  def create
    omniauth = env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

    if authentication
      session[:user_id] = authentication.user.id
      redirect_to root_url
    elsif current_user
      current_user.build_auth(omniauth).save!
      redirect_to edit_current_user_url
    else
      user = User.from_omniauth(omniauth)
      if user.valid?
        session[:user_id] = user.id
        redirect_to root_url
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_user_url
      end
    end
  end

  def destroy_auth
    return redirect_to edit_current_user_url, flash: {error: "You must have at least one linked account."} if current_user.authentications.length == 1

    authentication = current_user.authentications.find_by_provider(params[:provider])
    authentication.destroy
    redirect_to edit_current_user_url
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end

end
