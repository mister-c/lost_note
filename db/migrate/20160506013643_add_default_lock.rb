class AddDefaultLock < ActiveRecord::Migration
  def change
    change_column_default :notes, :is_locked, false
  end
end
