class AddUniqueContraint < ActiveRecord::Migration
  def change
    remove_index :notes, :unique_note_id
    add_index :notes, :unique_note_id, unique: true
  end
end
