class AddIsLockedToNote < ActiveRecord::Migration
  def change
    add_column :notes, :is_locked, :boolean
  end
end
