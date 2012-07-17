require 'open-uri'

class User < ActiveRecord::Base
  has_many :authentications

  validates :email, presence: true, uniqueness: true

  attr_accessible :avatar
  has_attached_file :avatar

  def self.from_omniauth(auth)
    create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    create do |user|
      user.authentications.build(provider: auth['provider'], uid: auth['uid'])
      user.name = auth["info"]["nickname"]
      user.picture_from_url auth["info"]["image"]
    end
  end

  def picture_from_url(url)
    self.avatar = open(url)
  end

  def has_facebook
    authentications.any? { |auth| auth.provider == "facebook" }
  end

  def has_twitter
    authentications.any? { |auth| auth.provider == "twitter" }
  end

end
