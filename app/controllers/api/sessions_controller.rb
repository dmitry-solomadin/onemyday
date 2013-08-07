class Api::SessionsController < Api::ApiController

  def social_auth
    begin
      omniauth = params[:omniauth]
      authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

      if authentication
        update_ios_device_token authentication.user
        render :json => {status: "ok"}.merge(UserFormat.get_hash(authentication.user))
      elsif params[:existing_user_id]
        user = User.find(params[:existing_user_id])
        add_auth_to_user user, omniauth
        update_ios_device_token user
        render :json => {status: "ok"}.merge(UserFormat.get_hash(user))
      else
        if omniauth["info"]["email"].present?
          existing_user = User.by_email(omniauth["info"]["email"])
          if existing_user
            add_auth_to_user existing_user, omniauth
            update_ios_device_token existing_user
            render :json => {status: "ok"}.merge(UserFormat.get_hash(existing_user))
            return
          end
        end

        user = User.from_omniauth(omniauth)
        if user.valid?
          update_ios_device_token user
          render :json => {status: "ok"}.merge(UserFormat.get_hash(user))
        else
          session[:omniauth] = omniauth.except('extra')
          render :json => {status: "user_is_invalid_cant_save"}.to_json
        end
      end
    rescue => e
      render json: {message: e.message, backtrace: e.backtrace}
    end
  end

  private

  def add_auth_to_user(user, omniauth)
    user.build_auth(omniauth).save!
  end

  def update_ios_device_token(user)
    # update user ios_device_token if provided
    if params[:ios_device_token]
      user.ios_device_token = params[:ios_device_token]
      user.save
    end
  end

end