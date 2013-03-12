OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV["TWITTER_CONSUMER_KEY"], ENV["TWITTER_CONSUMER_SECRET"]
  provider :facebook, ENV["FACEBOOK_APP_ID"], ENV["FACEBOOK_APP_SECRET"], scope: "email,publish_stream,publish_actions"
  provider :vkontakte, ENV['VKONTAKTE_API_KEY'], ENV['VKONTAKTE_API_SECRET'], scope: "email,notify,friends,photos"
end