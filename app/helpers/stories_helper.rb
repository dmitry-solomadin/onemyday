module StoriesHelper

  include MiniMagick
  include Faker

  def get_image_dims image_path
    {height: MiniMagick::Image.open(image_path)[:height], width: MiniMagick::Image.open(image_path)[:width]}
  end

  def get_image_time_taken image_path
    image = MiniMagick::Image.open(image_path)

    # trying to get time taken from exif
    time_taken = DateTime.strptime(image["EXIF:DateTime"], "%Y:%m:%d %H:%M:%S").strftime("%I:%M %P") rescue ""

    # if there is no exif try to get it from file name (use iPhone standard for now)
    if time_taken.blank?
      filename = File.basename(image_path)
      time_taken = DateTime.strptime(filename, "%Y-%m-%d %H.%M.%S").strftime("%I:%M %P") rescue ""
    end

    time_taken
  end

  def get_lorem
    Faker::Lorem.sentence 25
  end


end
