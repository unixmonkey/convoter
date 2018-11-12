class Conference < ApplicationRecord
  has_many :slots, -> { order(:starts_at) }
  scope :upcoming, -> { where arel_table[:ends_at].gt(Time.now) }

  def daynames
    (starts_at.to_i..ends_at.to_i).step(1.day.to_i).map do |second|
      Date::DAYNAMES[Time.at(second).wday]
    end
  end

  def slots_by_day
    slots.to_a.group_by { |slot| slot.name.reverse.split(' ', 4).last.reverse }
  end

  def current_day_index?(index)
    start_times = (starts_at.to_i..ends_at.to_i).step(1.day.to_i).map{ |second| Time.at(second) }
    today_index = start_times.map(&:today?).index(true)
    today_index == (index + 1)
  end
end
