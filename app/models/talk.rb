class Talk < ApplicationRecord
  belongs_to :slot
  has_many :votes
end
