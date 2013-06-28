class ActivityFormat

  def self.get_hash_for_multiple(activities)
    arr = []
    activities.each { |activity| arr << get_hash(activity) }
    arr
  end

  def self.get_hash(activity)
    activity_hash = {}.merge(activity.attributes)

    if activity.trackable
      trackable_name = activity.trackable_type.underscore.to_sym
      activity_hash[trackable_name] = {}

      if trackable_name == :comment or trackable_name == :like or trackable_name == :story
        activity_hash[trackable_name][:author_id] = activity.trackable.user.id
        activity_hash[trackable_name][:author_name] = activity.trackable.user.name
      end

      if trackable_name == :comment or trackable_name == :like
        activity_hash[trackable_name][:story_id] = activity.trackable.story.id
        activity_hash[trackable_name][:story_title] = activity.trackable.story.title
      end

      if trackable_name == :user
        activity_hash[trackable_name][:author_id] = activity.trackable.id
        activity_hash[trackable_name][:author_name] = activity.trackable.name
      end

      if trackable_name == :comment
        activity_hash[trackable_name][:text] = activity.trackable.text
      end

      if trackable_name == :story
        activity_hash[trackable_name][:story_title] = activity.trackable.title
      end
    end

    activity_hash
  end

end