class Story < ActiveRecord::Base
  attr_accessible :title, :type, :date, :date_text

  as_enum :type, regular: 0, work: 1, weekend: 2

  belongs_to :user
  has_many :story_photos

  validates_presence_of :type, :title, :date

  def date_text
    date_to_text date
  end

  def self.date_to_text time
    time.try(:strftime, "%d-%m-%Y")
  end

  def date_text=(time)
    self.date = Time.zone.parse(time)
  end

end
