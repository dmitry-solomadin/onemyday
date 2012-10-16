require 'open-uri'

class User < ActiveRecord::Base
  attr_accessible :avatar, :name, :locale

  has_many :authentications, dependent: :destroy
  has_many :stories
  has_many :likes, dependent: :destroy

  validates :email, presence: true, uniqueness: true

  paperclip_opts = {
      styles: {small: "50x50", thumb: "32x32"}
  }
  paperclip_opts.merge! PAPERCLIP_STORAGE_OPTS
  has_attached_file :avatar, paperclip_opts

  before_save :before_save

  def before_save
    self.facebook_link = self.facebook.get_object("me")["link"] if has_facebook?
    self.twitter_link = "http://twitter.com/#{self.twitter.user.screen_name}" if has_twitter?
  rescue Koala::Facebook::APIError => e
    logger.info e.to_s
  rescue Faraday::Error::ConnectionFailed => e
    logger.info e.to_s
  end

  def self.from_omniauth(auth)
    create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    create do |user|
      user.build_auth auth
      user.name = auth["info"]["nickname"]
      user.picture_from_url auth["info"]["image"]
    end
  end

  def build_auth auth
    self.authentications.build(provider: auth['provider'], uid: auth['uid'],
                               oauth_token: auth['credentials']['token'],
                               oauth_secret: auth['credentials']['secret'],
                               oauth_expires_at: auth['credentials']['expires_at'] ? Time.at(auth['credentials']['expires_at']) : nil)
  end

  def picture_from_url(url)
    self.avatar = open(url)
  end

  def has_facebook?
    authentications.any? { |auth| auth.provider == "facebook" }
  end

  def has_twitter?
    authentications.any? { |auth| auth.provider == "twitter" }
  end

  def facebook
    auth = self.authentications.find_by_provider("facebook")
    if auth
      @facebook ||= Koala::Facebook::API.new(auth.oauth_token)
    end
  end

  def twitter
    auth = self.authentications.find_by_provider("twitter")
    if auth
      @twitter ||= Twitter::Client.new(oauth_token: auth.oauth_token, oauth_token_secret: auth.oauth_secret)
    end
  end

  def liked_stories
    Story.includes(:likes).where(likes: {user_id: self.id})
  end

end
