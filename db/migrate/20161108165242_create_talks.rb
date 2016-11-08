class CreateTalks < ActiveRecord::Migration[5.0]
  def change
    create_table :talks do |t|
      t.references :slot, foreign_key: true
      t.string :title
      t.string :speaker
      t.text :speaker_detail
      t.text :synopsis

      t.timestamps
    end
  end
end
