class SessionsController < ApplicationController

  before_filter :signed_in_user_filter, only: [:destroy_auth]

  include SessionsHelper

  def create
    session[:user_to_create] = nil
    session[:omniauth] = nil
    if params[:password] && params[:email]
      existing_user = User.find_by_email(params[:email])
      unless existing_user
        session[:user_to_create] = User.new(email: params[:email], password: params[:password])
        return respond_to { |f| f.js }
      end

      if existing_user.password_digest.blank?
        @error_message = generate_existing_auth_message existing_user.auth_providers
      elsif existing_user.authenticate(params[:password])
        session[:user_id] = existing_user.id
      else
        @error_message =  t "sessions.create.wrong_password"
      end

      respond_to { |f| f.js }
    else
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
  end

  def destroy_auth
    @auth_destroyed = false
    if current_user.authentications.length > 1
      authentication = current_user.authentications.find_by_provider(params[:provider])
      authentication.destroy
      @auth_destroyed = true
    end

    respond_to { |t| t.js }
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end

end
