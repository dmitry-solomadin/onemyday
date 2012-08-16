class Like < ActiveRecord::Base
  attr_accessible :user_id

  belongs_to :user
  belongs_to :story

  validates :user, presence: true
  validates :story, presence: true
  validates_uniqueness_of :user_id, :scope => [:story_id]

end
