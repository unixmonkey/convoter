class Conference < ApplicationRecord
  has_many :slots
  scope :upcoming, -> { where arel_table[:ends_at].gt(Time.now) }
end
