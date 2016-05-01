class TimeToDeathRestrictions < ActiveRecord::Migration
  def change
    rename_column :notes, :TimeTilDeath, :time_til_death
    change_column_default :notes, :time_til_death, 30
  end
end
