require 'open-uri'

class User < ActiveRecord::Base
  attr_accessible :avatar
  has_attached_file :avatar

  def self.from_omniauth(auth)
    where(auth.slice("provider", "uid")).first || create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    create! do |user|
      user.provider = auth["provider"]
      user.uid = auth["uid"]
      user.name = auth["info"]["nickname"]
      user.picture_from_url auth["info"]["image"]
    end
  end

  def picture_from_url(url)
    self.avatar = open(url)
  end

end
