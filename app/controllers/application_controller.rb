class ApplicationController < ActionController::Base
  protect_from_forgery

  def signed_in_user_filter
    redirect_to root_url, notice: "Please sign in." unless signed_in?
  end

  def is_current_user user
    signed_in? && user == current_user
  end

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def signed_in?
    !current_user.nil?
  end

  helper_method [:current_user, :is_current_user]

end
