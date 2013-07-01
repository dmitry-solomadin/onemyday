class StoryText < ActiveRecord::Base
  attr_accessible :text, :element_order

  has_one :story_element, :as => :element
  has_one :story, :through => :story_element

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

end
