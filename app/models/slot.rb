class Slot < ApplicationRecord
  belongs_to :conference
  has_many :talks
end
