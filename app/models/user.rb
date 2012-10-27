require 'open-uri'

class User < ActiveRecord::Base
  attr_accessible :email, :avatar, :name, :locale, :gender

  has_many :authentications, dependent: :destroy
  has_many :stories
  has_many :likes, dependent: :destroy

  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
           class_name:  "Relationship",
           dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower

  validates :email, presence: true, uniqueness: true
  validates_presence_of :name
  validates_format_of :email, with: /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/

  paperclip_opts = {
      styles: {small: "50x50", thumb: "32x32"}
  }
  paperclip_opts.merge! PAPERCLIP_STORAGE_OPTS
  has_attached_file :avatar, paperclip_opts

  after_save :after_save, if: :authentications_changed?

  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end

  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end

  def male?
    self.gender == "male"
  end

  def authentications_changed?
    @auth_changed
  end

  # todo do this only if associations is changed
  def after_save
    update_social_links
    update_social_gender
    @auth_changed = false
  end

  def self.from_omniauth(auth)
    create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    create do |user|
      user.build_auth auth
      user.name = auth["info"]["nickname"]
      user.picture_from_url auth["info"]["image"]
      @auth_changed = true
    end
  end

  def build_auth auth
    self.authentications.build(provider: auth['provider'], uid: auth['uid'],
                               oauth_token: auth['credentials']['token'],
                               oauth_secret: auth['credentials']['secret'],
                               oauth_expires_at: auth['credentials']['expires_at'] ? Time.at(auth['credentials']['expires_at']) : nil)
    @auth_changed = true
    self
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

  def update_social_gender
    if has_facebook?
      fb_gender = self.facebook.get_object("me")["gender"]
      self.gender = fb_gender if fb_gender.length > 0
    end
  rescue Koala::Facebook::APIError => e
    logger.info e.to_s
  rescue Faraday::Error::ConnectionFailed => e
    logger.info e.to_s
  end

  def update_social_links
    self.facebook_link = self.facebook.get_object("me")["link"] if has_facebook?
    self.twitter_link = "http://twitter.com/#{self.twitter.user.screen_name}" if has_twitter?
  rescue Koala::Facebook::APIError => e
    logger.info e.to_s
  rescue Faraday::Error::ConnectionFailed => e
    logger.info e.to_s
  end

end
