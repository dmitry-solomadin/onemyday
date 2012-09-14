module StoriesHelper

  EXPLORE_FILTER_POPULAR = 1
  EXPLORE_FILTER_RECENT = 2

  include Faker

  def get_lorem
    Faker::Lorem.sentence 25
  end

end
