class Comment < ActiveRecord::Base
  attr_accessible :text

  belongs_to :story
  belongs_to :comment
  belongs_to :user

  has_many :comments, dependent: :destroy

  validates_presence_of :text
  validates :user, presence: true
  validates :story, presence: true

end
