class StoryPhoto < ActiveRecord::Base
  attr_accessible :order, :caption, :date, :date_text, :photo, :orientation

  as_enum :orientation, left: 0, center: 1, right: 2

  belongs_to :story

  paperclip_opts = {
      styles: { center: "x550", side: "450x550>", thumb: "250x" }
  }
  paperclip_opts.merge! ENV["S3_PARAMETERS"] unless Rails.env.development?

  has_attached_file :photo, paperclip_opts

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
