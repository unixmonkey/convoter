class Conference < ApplicationRecord
  scope :upcoming, -> { where arel_table[:ends_at].gt(Time.now) }
end
