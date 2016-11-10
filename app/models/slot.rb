class Slot < ApplicationRecord
  belongs_to :conference
  has_many :talks
  has_many :votes, through: :talks
end
