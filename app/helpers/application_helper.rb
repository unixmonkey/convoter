module ApplicationHelper
  def active_day?(conference, loop_index, day_index)
    if day_index.present?
      day_index == loop_index.to_s
    else
      @conference.current_day_index?(loop_index)
    end
  end
end
