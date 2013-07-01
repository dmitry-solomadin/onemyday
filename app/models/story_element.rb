class StoryElement < ActiveRecord::Base
  attr_accessible :element, :story, :element_order

  belongs_to :story
  belongs_to :element, :polymorphic => true

  default_scope :order => 'element_order ASC'

  before_save :before_save

  def before_save
    if not self.element_order and element.element_order
      self.element_order = element.element_order
    end
  end

end