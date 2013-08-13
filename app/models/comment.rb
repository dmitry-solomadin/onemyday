class Comment < ActiveRecord::Base
  attr_accessible :text

  belongs_to :story, counter_cache: true
  belongs_to :comment
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :activities, as: :trackable, dependent: :destroy

  validates_presence_of :text
  validates :user, presence: true
  validates :story, presence: true

  scope :by_date, -> { order("created_at") }

  def created_at_nice
    Comment.created_at_nice created_at
  end

  def self.created_at_nice date
    date.try(:strftime, "%b %d %Y at %H:%M")
  end

  # Override getter method for document association
  def story_with_unscoped
    # Fetch document with default scope disabled
    Story.unscoped { story_without_unscoped }
  end
  alias_method_chain :story, :unscoped

end
