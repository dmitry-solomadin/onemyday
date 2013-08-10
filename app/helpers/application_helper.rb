module ApplicationHelper

  def facebook_like_meta(title, url, image)
    [
        tag('meta', :property => 'og:title', :content => title),
        tag('meta', :property => 'og:type', :content => 'blog'),
        tag('meta', :property => 'og:image', :content => image),
        tag('meta', :property => 'og:url', :content => url),
        tag('meta', :property => 'og:site_name', :content => 'Onemyday'),
        tag('meta', :property => 'fb:admins', :content => '1499932287')
    ].join("\n").html_safe
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_user? user
    current_user && user == current_user
  end

  def get_title(title)
    !title.blank? ? title : "Onemyday"
  end

  def current_locale
    I18n.locale
  end

end
