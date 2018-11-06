class AddKeynoteToTalks < ActiveRecord::Migration[5.2]
  def change
    add_column :talks, :keynote, :boolean, default: false
  end
end
