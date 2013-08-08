class Team < ActiveRecord::Base
  attr_accessible :code, :image_file_name, :name, :nickname, :city

  validates :code, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 3 }
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 30 }
  validates :city, presence: true, length: { maximum: 30 }
  validates :nickname, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 30 }

  has_many :home_games, class_name: "Game", inverse_of: :home_team
  has_many :away_games, class_name: "Game", inverse_of: :away_team
end
