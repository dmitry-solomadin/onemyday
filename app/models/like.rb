class Like < ActiveRecord::Base
  attr_accessible :user_id

  belongs_to :user
  belongs_to :story, counter_cache: true

  has_many :activities, as: :trackable, dependent: :destroy

  validates :user, presence: true
  validates :story, presence: true
  validates_uniqueness_of :user_id, :scope => [:story_id]

end
