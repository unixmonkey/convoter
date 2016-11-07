class CreateConferences < ActiveRecord::Migration[5.0]
  def change
    create_table :conferences do |t|
      t.text :description
      t.string :name, limit: 255
      t.string :year, limit: 4
      t.timestamp :starts_at
      t.timestamp :ends_at

      t.timestamps
    end
  end
end
