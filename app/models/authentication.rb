class Authentication < ActiveRecord::Base
  attr_accessible :provider, :uid, :oauth_token, :oauth_secret, :oauth_expires_at
  belongs_to :user, touch: true

  validates_presence_of :provider, :uid
end
