class Api::UsersController < Api::ApiController

  def update
    begin
      user = User.find(params[:id])
      if user.update_attributes(params[:user])
        render json: {success: true}
      else
        render json: {errors: user.errors, status: "bad_request"}.to_json
      end
    rescue => e
      render json: {message: e.message, backtrace: e.backtrace}
    end
  end

end