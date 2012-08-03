class StoryPhoto < ActiveRecord::Base
  attr_accessible :order, :photo

  belongs_to :story
  has_attached_file :photo, styles: { medium: "500x450>", thumb: "100>x100" }
end
