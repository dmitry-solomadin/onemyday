class Api::SessionsController < Api::ApiController

  def social_auth
    begin
      omniauth = params[:omniauth]
      authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

      if authentication
        render :json => {status: status}.merge(UserFormat.get_hash(authentication.user))
      elsif params[:existing_user_id]
        user = User.find(params[:existing_user_id])
        add_auth_to_user user, omniauth
        render :json => {status: status}.merge(UserFormat.get_hash(user))
      else
        if auth["info"]["email"].present?
          existing_user = User.find_by_email(auth["info"]["email"])
          if existing_user
            add_auth_to_user existing_user, omniauth
            render :json => {status: status}.merge(UserFormat.get_hash(existing_user))
            return
          end
        end

        user = User.from_omniauth(omniauth)
        if user.valid?
          render :json => {status: status}.merge(UserFormat.get_hash(user))
        else
          session[:omniauth] = omniauth.except('extra')
          status = "no_email_error"
          render :json => {status: status}.to_json
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

end