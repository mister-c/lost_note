class IdLengthContrain < ActiveRecord::Migration
  def change
    add_index :notes, :unique_note_id, length: 20
  end
end
