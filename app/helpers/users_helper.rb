module UsersHelper

  def get_available_locales
    {"Choose Locale" => nil, "English" => "en", "Russian" => "ru"}
  end

  def get_his_stories_header user
    return t 'users.show.stories' if !user || user.gender.blank?
    user.male? ? t('users.show.his') : t('users.show.her')
  end

end
