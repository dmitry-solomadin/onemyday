class StoryPhoto < ActiveRecord::Base
  attr_accessible :order, :photo

  belongs_to :story
  has_attached_file :photo, styles: { medium: "300x300>", thumb: "100x100>" }
end
