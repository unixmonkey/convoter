class Conference < ApplicationRecord
  has_many :slots, -> { order(:id) }
  scope :upcoming, -> { where arel_table[:ends_at].gt(Time.now) }

  def daynames
    (starts_at.to_i..ends_at.to_i).step(1.day.to_i).map do |second|
      Date::DAYNAMES[Time.at(second).wday]
    end
  end

  def slots_by_day
    slots.to_a.group_by { |slot| slot.name.reverse.split(' ', 4).last.reverse }
  end
end
