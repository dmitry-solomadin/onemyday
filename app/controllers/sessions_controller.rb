class SessionsController < ApplicationController

  def create
    omniauth = env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

    if authentication
      session[:user_id] = authentication.user.id
      redirect_to root_url, notice: "Signed in!"
    elsif current_user
      current_user.authentications.create!(provider: omniauth['provider'], uid: omniauth['uid'])
      redirect_to root_url, notice: "Signed in!"
    else
      user = User.from_omniauth(omniauth)
      if user.valid?
        session[:user_id] = user.id
        redirect_to root_url, notice: "Signed in!"
      else
        session[:omniauth] = omniauth.except('extra')
        redirect_to new_users_url
      end
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Signed out!"
  end

end
