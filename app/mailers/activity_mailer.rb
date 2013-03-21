class ActivityMailer < ActionMailer::Base
  include I18n

  default from: "onemyday.co@gmail.com"
  DEFAULT_MAIL = "dmitry.solomadin@gmail.com"

  def self.activity_mail(activity)
    mailto = activity.user.email
    mailto = DEFAULT_MAIL if Rails.env.development?
    I18n.locale = activity.user.locale if activity.user.locale

    case activity.trackable_type.underscore.to_sym
      when :comment
        self.comment_mail(mailto, activity)
      when :like
        self.like_mail(mailto, activity)
      when :story
        self.story_mail(mailto, activity)
      when :user
        self.user_mail(mailto, activity)
      else
        raise "No mail method for trackable_type: #{activity.trackable_type}"
    end
  end

  def comment_mail(mailto, activity)
    @activity = activity
    @comment = activity.trackable
    if @activity.reason == "discussion_member"
      subject = I18n.t("activity_mailer.comment_mail.subject_discussion", username: @comment.user.name)
    else
      subject = I18n.t("activity_mailer.comment_mail.subject", username: @comment.user.name)
    end
    mail to: mailto, subject: subject
  end

  def like_mail(mailto, activity)
    @activity = activity
    @like = activity.trackable
    subject = I18n.t("activity_mailer.like_mail.subject", username: @like.user.name)
    mail to: mailto, subject: subject
  end

  def story_mail(mailto, activity)
    @activity = activity
    @story = activity.trackable
    subject = I18n.t("activity_mailer.story_mail.subject", username: @story.user.name)
    mail to: mailto, subject: subject
  end

  def user_mail(mailto, activity)
    @activity = activity
    @user = activity.trackable
    subject = I18n.t("activity_mailer.user_mail.subject", username: @user.name)
    mail to: mailto, subject: subject
  end

end
