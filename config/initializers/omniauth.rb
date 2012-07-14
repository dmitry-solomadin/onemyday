OmniAuth.config.logger = Rails.logger

puts "initializing twitter with #{ENV['TWITTER_KEY']}, #{ENV['TWITTER_SECRET']}"
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, "3Ot3E3BhpTFV5inPVXOw", "mNtee7A5W87WdMDlIBHCRQURv29ECTsKUlWoArY0A"
end