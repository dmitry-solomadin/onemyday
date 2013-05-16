class Api::ApiController < ApplicationController
  respond_to :json
  layout nil
  before_filter :check_api_key
  skip_filter :signed_in_user_filter

  def check_api_key
    if !params[:api_key] or params[:api_key] != ENV["ONEMYDAY_API_KEY"]
      raise "AccessDenied"
    end
  end

end