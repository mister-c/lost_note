class AddTimeTilDeathAttribToNote < ActiveRecord::Migration
  def change
    #Time until the death of the note in minutes
    add_column :notes, :TimeTilDeath, :integer
  end
end
