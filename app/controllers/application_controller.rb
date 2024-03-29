class ApplicationController < ActionController::Base
  class Onemyday::AccessDenied < StandardError
  end

  protect_from_forgery

  layout ->(c) { c.request.xhr? ? false : "application" }

  include ApplicationHelper

  before_filter :set_locale

  rescue_from Onemyday::AccessDenied, :with => :access_denied

  private

  def set_locale
    if params[:custom_locale]
      I18n.locale = params[:custom_locale]
    elsif current_user && !current_user.locale.blank?
      I18n.locale = current_user.locale
    else
      location = request.location
      logger.info "User location #{location.inspect}"
      if location
        country_code = location.country_code
        if country_code == "UA" || country_code == "RU"
          I18n.locale = :ru
          @locale = :ru.to_s
        else
          I18n.locale = I18n.default_locale
          @locale = I18n.default_locale.to_s
        end
      else
        I18n.locale = I18n.default_locale
        @locale = I18n.default_locale.to_s
      end
    end
  end

  def signed_in_user_filter
    redirect_to root_url, notice: "Please sign in." unless current_user
  end

  def access_denied
    redirect_to root_url, notice: "You are unauthorized to view this content."
  end

end
