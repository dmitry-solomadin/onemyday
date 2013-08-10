class StoryPhoto < ActiveRecord::Base
  attr_accessible :photo_order, :caption, :date, :date_text, :photo, :orientation, :photo_dimensions, :time_taken, :has_text, :element_order

  as_enum :orientation, left: 0, center: 1, right: 2

  has_one :story_element, :as => :element
  has_one :story, :through => :story_element

  @paperclip_opts = {
      styles: {center: "x550", side: "420x550>", thumb: "300x",
               iphone2x_thumb: "600x600", iphone2x: "600x"}
  }
  @paperclip_opts.merge! PAPERCLIP_STORAGE_OPTS

  has_attached_file :photo, @paperclip_opts

  after_post_process :save_photo_additional_info
  serialize :photo_dimensions
  after_initialize :init_defaults

  def element_order=(order)
    @element_order = order
    if story_element
      story_element.element_order = order
      story_element.save!
    end
  end

  def element_order
    @element_order
  end

  def init_defaults
    self.orientation ||= :left
  end

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

  def photo_urls
    r = {}
    self.photo_dimensions.each_key { |key| r["#{key}_url"] = self.photo.url(key) }
    r
  end

  def caption_for_alt
    has_text ? caption[0...200] : ""
  end

end
