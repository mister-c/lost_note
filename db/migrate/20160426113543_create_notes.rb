class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
      t.texxt :text
      t.string :unique_note_id

      t.timestamps null: false
    end
  end
end
