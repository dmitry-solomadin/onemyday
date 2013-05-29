class ActivityTracking

  def self.track(trackable, user, reason = "regular")
    activity = user.activities.create! reason: reason, trackable: trackable
    ActivityMailer.delay.activity_mail(activity)
  end

end