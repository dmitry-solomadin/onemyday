class View < ActiveRecord::Base
  attr_accessible :date

  belongs_to :story, counter_cache: true

  validates_presence_of :date
end
