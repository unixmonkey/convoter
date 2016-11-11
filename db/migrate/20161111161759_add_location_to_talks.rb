class AddLocationToTalks < ActiveRecord::Migration[5.0]
  def change
    add_column :talks, :location, :string
  end
end
