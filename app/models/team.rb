class Team < ActiveRecord::Base
  attr_accessible :code, :image_file_name, :name, :nickname
end
