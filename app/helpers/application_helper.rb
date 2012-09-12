module ApplicationHelper

  def facebook_like_meta(title, url, image)
    [
        tag('meta', :property => 'og:title', :content => title),
        tag('meta', :property => 'og:type', :content => 'blog'),
        tag('meta', :property => 'og:image', :content => image),
        tag('meta', :property => 'og:url', :content => url),
        tag('meta', :property => 'og:site_name', :content => 'Singleday'),
        tag('meta', :property => 'fb:admins', :content => '1499932287')
    ].join("\n").html_safe
  end

end
