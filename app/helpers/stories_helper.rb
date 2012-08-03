module StoriesHelper

  include MiniMagick
  include Faker

  def get_image_dims image_path
    {
        height: MiniMagick::Image.open(image_path)[:height],
        width: MiniMagick::Image.open(image_path)[:width],
    }
  end

  def get_lorem
    Faker::Lorem.sentence 25
  end


end
