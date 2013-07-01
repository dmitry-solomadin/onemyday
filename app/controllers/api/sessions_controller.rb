class Api::SessionsController < Api::ApiController

  def social_auth
    begin
      omniauth = params[:omniauth]
      authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])

      if authentication
        render :json => {status: "found_authentication"}.merge(UserFormat.get_hash(authentication.user))
      elsif params[:existing_user_id]
        User.find(params[:existing_user_id]).build_auth(omniauth).save!
        render :json => {status: "found_user_added_auth"}.merge(UserFormat.get_hash(current_user))
      else
        user = User.from_omniauth(omniauth)
        if user.valid?
          render :json => {status: "created_user"}.merge(UserFormat.get_hash(user))
        else
          render :json => {status: "cant_create_user"}.to_json
        end
      end
    rescue => e
      render json: {message: e.message, backtrace: e.backtrace}
    end
  end

end