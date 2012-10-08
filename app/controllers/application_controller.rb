class ApplicationController < ActionController::Base
  protect_from_forgery

  layout ->(c) { c.request.xhr? ? false : "application" }

  include ApplicationHelper

  def signed_in_user_filter
    redirect_to root_url, notice: "Please sign in." unless current_user
  end

  def get_title(title)
    !title.blank? ? title : "Singleday"
  end

  def meta_tags meta_tags
    !meta_tags.blank? ? meta_tags : ""
  end

  helper_method [:get_title, :meta_tags]

end
