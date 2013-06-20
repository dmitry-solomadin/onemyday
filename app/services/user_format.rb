class UserFormat

  def self.get_hash(user)
    user_hash = {user: user}
    user_hash[:user][:followers_size] = user.followers_size
    user_hash[:user][:followed_by_size] = user.followed_by_size
    user_hash[:user][:stories_size] = user.stories_size
    user_hash[:user][:avatar_urls] = user.avatar_urls
    user_hash
  end

end