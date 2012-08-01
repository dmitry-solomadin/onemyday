class AddMoreUserInfoController < ApplicationController

  def show

  end

  def submit
    current_user.job_title = params[:user][:job_title]
    current_user.company = params[:user][:company]
    current_user.save

    redirect_to new_stories_url
  end

end
