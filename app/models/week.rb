class Week < ActiveRecord::Base
  #attr_accessible :season_id, :week_num, :status
  validates :season_id, presence: true
  validates :week_num, presence: true, uniqueness: { scope: :season_id, message: "should happen once per year" }
  validates :status, inclusion: { in: %w(NOT_STARTED STARTED COMPLETE PUBLISHED), message: "%{value} is not NOT_STARTED STARTED COMPLETE or PUBLISHED" }


  belongs_to :season
  has_many :games, dependent: :destroy
  has_many :entries, dependent: :destroy
end
