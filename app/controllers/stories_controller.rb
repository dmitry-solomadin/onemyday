class StoriesController < ApplicationController

  before_filter :signed_in_user_filter, only: [:new]

  def new
    return redirect_to moreinfo_url if current_user.job_title.blank? || current_user.company.blank?

    render "new"
  end

end
