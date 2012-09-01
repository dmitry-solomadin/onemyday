module StoriesHelper

  include Faker

  def get_lorem
    Faker::Lorem.sentence 25
  end

end
