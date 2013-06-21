class Entry < ActiveRecord::Base
  attr_accessible :status, :tiebreak, :user_id
end
