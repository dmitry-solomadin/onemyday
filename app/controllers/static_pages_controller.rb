class StaticPagesController < ApplicationController

  layout false

  def channel

  end

  def landing
    render layout: "application"
  end

  def contacts
    render layout: "application"
  end

end
