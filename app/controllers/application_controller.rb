class ApplicationController < ActionController::Base
  protect_from_forgery

  layout ->(c) { c.request.xhr? ? false : "application" }

  include ApplicationHelper

  before_filter :set_locale

  private

  def set_locale
    I18n.locale = :ru
    return

    if current_user && !current_user.locale.blank?
      I18n.locale = current_user.locale
    else
      location = request.location
      logger.info "User location #{location.inspect}"
      if location
        country_code = location.country_code
        if country_code == "UA" || country_code == "RU"
          I18n.locale = :ru
        else
          I18n.locale = I18n.default_locale
        end
      else
        I18n.locale = I18n.default_locale
      end
    end
  end

  def signed_in_user_filter
    redirect_to root_url, notice: "Please sign in." unless current_user
  end

end
