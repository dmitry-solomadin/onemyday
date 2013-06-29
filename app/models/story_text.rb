class StoryText < ActiveRecord::Base
  attr_accessible :text, :element_order
  attr_accessor :element_order

  has_one :story_element, :as => :element
  has_one :story, :through => :story_element
end
