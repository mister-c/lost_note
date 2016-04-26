class AddDefaultText < ActiveRecord::Migration
  def change
    change_column_default :notes, :unique_note_id, ""
    change_column_default :notes, :text, ""
  end
end
