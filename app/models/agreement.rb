class Agreement < ActiveRecord::Base

  belongs_to :user
  belongs_to :season

  validates :user_id, presence: true
  validates :season_id, presence: true
end
