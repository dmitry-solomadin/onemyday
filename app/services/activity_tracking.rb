class ActivityTracking
  include I18n

  def self.track(trackable, user, reason = "regular")
    activity = user.activities.create! reason: reason, trackable: trackable
    if user.ios_device_token.present?
      env = "development" # todo replace this with Rails.env when production is ready
      apn_notify(env, user.ios_device_token,
                 {alert: get_text(activity), badge: user.activities.unseen.size, sound: true})
    end
    ActivityMailer.delay.activity_mail(activity)
  end

  def self.get_text(activity)
    case activity.trackable_type.underscore.to_sym
      when :comment
        I18n.t("activities.new_comment_text", username: activity.trackable.user.name)
      when :like
        I18n.t("activities.new_like_text", username: activity.trackable.user.name)
      when :story
        I18n.t("activities.new_story_text", username: activity.trackable.user.name)
      when :user
        I18n.t("activities.new_user_text", username: activity.trackable.user.name)
      else
        raise "Can't find activity text for trackable_type: #{activity.trackable_type}"
    end
  end

  def self.apn_notify(env, token, opts)
    notification = Rapns::Apns::Notification.new
    notification.app = Rapns::Apns::App.find_by_name("onemyday_#{env}")
    notification.device_token = token
    notification.alert = opts[:alert] if opts[:alert]
    notification.badge = opts[:badge] if opts[:badge]
    notification.sound = opts[:sound] if opts[:sound]
    notification.save!
  end

end