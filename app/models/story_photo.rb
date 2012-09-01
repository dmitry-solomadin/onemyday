class StoryPhoto < ActiveRecord::Base
  attr_accessible :order, :caption, :date, :date_text, :photo, :orientation, :photo_dimensions, :time_taken

  as_enum :orientation, left: 0, center: 1, right: 2

  belongs_to :story

  @paperclip_opts = {
      styles: {center: "x550", side: "450x550>", thumb: "250x"}
  }
  @paperclip_opts.merge! PAPERCLIP_STORAGE_OPTS

  has_attached_file :photo, @paperclip_opts

  after_post_process :save_photo_additional_info
  serialize :photo_dimensions

  def save_photo_additional_info
    save_photo_dimensions
    save_time_taken
  end

  def save_photo_dimensions
    original_geo = Paperclip::Geometry.from_file(photo.queued_for_write[:original])

    self.photo_dimensions = {
        original: {width: original_geo.width, height: original_geo.height}
    }

    StoryPhoto.instance_variable_get(:@paperclip_opts)[:styles].each_key do |style|
      geo = Paperclip::Geometry.from_file(photo.queued_for_write[style])
      self.photo_dimensions[style] = {}
      self.photo_dimensions[style][:width] = geo.width
      self.photo_dimensions[style][:height] = geo.height
    end
  end

  def save_time_taken
    file = photo.queued_for_write[:original]
    file_path = file.respond_to?(:path) ? file.path : file
    image = MiniMagick::Image.open(file_path)

    # trying to get time taken from exif
    time_taken = DateTime.strptime(image["EXIF:DateTime"], "%Y:%m:%d %H:%M:%S").strftime("%I:%M %P") rescue ""

    # if there is no exif try to get it from file name (use iPhone standard for now)
    if time_taken.blank?
      filename = File.basename(file_path)
      time_taken = DateTime.strptime(filename, "%Y-%m-%d %H.%M.%S").strftime("%I:%M %P") rescue ""
    end

    self.time_taken = time_taken
  end

  def date_text
    StoryPhoto.date_to_text date
  end

  def date_text=(time)
    self.date = Time.zone.parse(time)
  end

  def self.date_to_text time
    time.try(:strftime, "%I:%M %P")
  end

end
