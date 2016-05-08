class AddDefaultMaxRead < ActiveRecord::Migration
  def change
    change_column_default :notes, :max_num_read, 1
  end
end
