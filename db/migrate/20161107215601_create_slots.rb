class CreateSlots < ActiveRecord::Migration[5.0]
  def change
    create_table :slots do |t|
      t.string :name
      t.references :conference, foreign_key: true
      t.timestamp :starts_at
      t.timestamp :ends_at

      t.timestamps
    end
  end
end
