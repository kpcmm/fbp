class Season < ActiveRecord::Base
  attr_accessible :year
  validates :year, presence: true,  uniqueness: true

  has_many :weeks, dependent: :destroy
end
