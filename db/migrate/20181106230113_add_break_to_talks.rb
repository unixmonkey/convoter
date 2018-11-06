class AddBreakToTalks < ActiveRecord::Migration[5.2]
  def change
    add_column :talks, :break, :boolean, default: false
  end
end
