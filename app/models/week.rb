class Week < ActiveRecord::Base
  attr_accessible :season_id, :week_num
  validates :season_id, presence: true
  validates :week_num, presence: true, uniqueness: { scope: :season_id, message: "should happen once per year" }

  belongs_to :season
  has_many :games, dependent: :destroy
  has_many :entries
end
