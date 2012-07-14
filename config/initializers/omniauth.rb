OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, "3Ot3E3BhpTFV5inPVXOw", "mNtee7A5W87WdMDlIBHCRQURv29ECTsKUlWoArY0A"
  provider :facebook, "272763286172620", "e347de77c945e9a8ea95e9548e8a9a31"
end