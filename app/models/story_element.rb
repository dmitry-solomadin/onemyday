class StoryElement < ActiveRecord::Base
  attr_accessible :element, :story, :element_order

  belongs_to :story
  belongs_to :element, :polymorphic => true

  default_scope :order => 'element_order ASC'

end