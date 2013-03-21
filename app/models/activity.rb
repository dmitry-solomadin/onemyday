class Activity < ActiveRecord::Base
  attr_accessible :reason, :trackable

  scope :unseen, where(viewed: false)

  belongs_to :user
  belongs_to :trackable, polymorphic: true
end
