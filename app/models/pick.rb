class Pick < ActiveRecord::Base
  attr_accessible :entry_id, :game_id, :pick, :points
  validates :entry_id, presence: true
  validates :game_id, presence: true, uniqueness: { scope: :entry_id }
  validates :pick, presence: true, inclusion: { in: %w(HOME AWAY NONE), message: "%{value} is not HOME or AWAY or NONE" }
  #validates :points, presence: true, uniqueness: { scope: :entry_id }

  #belongs_to :entry
  #belongs_to :game
end
