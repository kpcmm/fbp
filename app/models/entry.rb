class Entry < ActiveRecord::Base
  attr_accessible :status, :tiebreak, :user_id, :week_id
  validates :status, presence: true, inclusion: { in: %w(NEW INCOMPLETE COMPLETE LOCKED), message: "%{value} is not NEW, INCOMPLETE, COMPLETE or LOCKED" }
  validates :user_id, presence: true

  belongs_to :user
  belongs_to :week
  has_many :picks, dependent: :destroy
end
