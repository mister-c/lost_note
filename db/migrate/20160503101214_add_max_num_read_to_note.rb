class AddMaxNumReadToNote < ActiveRecord::Migration
  def change
    add_column :notes, :max_num_read, :int
  end
end
