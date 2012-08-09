class StoryPhoto < ActiveRecord::Base
  attr_accessible :order, :caption, :date, :photo

  as_enum :orientation, left: 0, center: 1, right: 2

  belongs_to :story
  has_attached_file :photo, styles: { medium: "450x550>", thumb: "100>x100" }
end
