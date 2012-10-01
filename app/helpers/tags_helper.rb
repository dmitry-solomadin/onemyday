module TagsHelper

  def get_popular_tags(lim = 5)
    Story.tag_counts_on(:tags).order("count DESC").limit(5)
  end

end
