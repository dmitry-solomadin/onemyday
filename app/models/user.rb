require 'open-uri'

class User < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  attr_accessible :email, :avatar, :name, :locale, :gender, :password
  has_secure_password

  has_many :authentications, dependent: :destroy
  has_many :stories
  has_many :likes, dependent: :destroy

  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
           class_name: "Relationship",
           dependent: :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  has_many :activities

  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true,
            uniqueness: {case_sensitive: false}
  validates :email, format: {with: VALID_EMAIL_REGEX}, if: ->{ self.email.present? }
  validates :password, length: {minimum: 6}, if: :validate_password?

  # remove password_digest error if authentications present.
  validate do
    errors.each { |attribute| errors.delete(attribute) if attribute == :password_digest } if self.authentications.any?
  end

  @paperclip_opts = {
      styles: {small: "50x50", thumb: "32x32"}, default_url: "/assets/no-avatar.png"
  }
  @paperclip_opts.merge! PAPERCLIP_STORAGE_OPTS
  has_attached_file :avatar, @paperclip_opts
  class << self; attr_accessor :paperclip_opts end

  before_save :before_save
  def before_save
    self.email = email.downcase
    update_social_info
  end

  def feed
    Story.from_users_followed_by self
  end

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
    # compare authentications size in db and in memory
    authentications.length != authentications.count
  end

  def update_social_info
    return unless authentications_changed?
    update_social_links
    update_social_gender
  end

  def self.from_omniauth(auth)
    create_from_omniauth(auth)
  end

  def self.create_from_omniauth(auth)
    create do |user|
      user.build_auth auth
      user.name = User.get_omniauth_name(auth)
      user.email = auth["info"]["email"] if auth["info"]["email"].present?
      user.picture_from_url auth["info"]["image"]
    end
  end

  def self.get_omniauth_name(auth)
    if auth["info"]["first_name"].present? && auth["info"]["last_name"].present?
      return "#{auth['info']['first_name']} #{auth['info']['last_name']}"
    elsif auth["info"]["nickname"].present?
      return auth["info"]["nickname"]
    end
  end

  def build_auth auth
    self.authentications.build(provider: auth['provider'], uid: auth['uid'],
                               oauth_token: auth['credentials']['token'],
                               oauth_secret: auth['credentials']['secret'],
                               oauth_expires_at: auth['credentials']['expires_at'] ? Time.at(auth['credentials']['expires_at']) : nil)
    self
  end

  def picture_from_url(url)
    self.avatar = open(url)
  end

  def auth_providers
    authentications.collect { |auth| auth.provider }
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
      @facebook ||= init_auth(auth)
    end
  end

  def twitter
    auth = self.authentications.find_by_provider("twitter")
    if auth
      @twitter ||= init_auth(auth)
    end
  end

  def liked_stories
    Story.includes(:likes).where(likes: {user_id: self.id})
  end

  def update_social_gender
    if has_facebook?
      fb_gender = find_auth("facebook").get_object("me")["gender"]
      self.gender = fb_gender if fb_gender.length > 0
    end
  rescue Koala::Facebook::APIError => e
    logger.info e.to_s
  rescue Faraday::Error::ConnectionFailed => e
    logger.info e.to_s
  end

  def update_social_links
    self.facebook_link = find_auth("facebook").get_object("me")["link"] if has_facebook?
    self.twitter_link = "http://twitter.com/#{find_auth("twitter").user.screen_name}" if has_twitter?
  rescue Koala::Facebook::APIError => e
    logger.info e.to_s
  rescue Faraday::Error::ConnectionFailed => e
    logger.info e.to_s
  end

  def avatar_urls
    urls = {}
    User.paperclip_opts[:styles].each_key { |photo_style| urls["#{photo_style}_url"] = self.avatar.url(photo_style.to_sym) }
    urls
  end

  private

  def validate_password?
    !((self.password_digest.present? && self.password.blank?) || self.password_digest.blank?)
  end

  def find_auth(auth_name)
    auth = authentications.find { |auth| auth.provider == auth_name }
    init_auth auth
  end

  def init_auth(auth)
    if auth.provider == "facebook"
      Koala::Facebook::API.new(auth.oauth_token)
    elsif auth.provider == "twitter"
      Twitter::Client.new(oauth_token: auth.oauth_token, oauth_token_secret: auth.oauth_secret)
    end
  end

end
