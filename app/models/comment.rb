class Comment < ActiveRecord::Base
  attr_accessible :text

  belongs_to :story, counter_cache: true
  belongs_to :comment
  belongs_to :user

  has_many :comments, dependent: :destroy

  validates_presence_of :text
  validates :user, presence: true
  validates :story, presence: true

  def created_at_nice
    Comment.created_at_nice created_at
  end

  def self.created_at_nice date
    date.try(:strftime, "%b %d %Y at %M:%S")
  end

end
