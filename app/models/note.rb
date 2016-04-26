class Note < ActiveRecord::Base
  class_attribute adj_list
  class_attribute noun_list
  class_attribute rng

  adj_file  = open("lib/asset/simple_adj.txt")
  noun_file = open("lib/asset/simple_noun.txt")
  Note.adj_list = adj_file.read
  adj_file.close
  Note.noun_list = noun_file.read
  noun_file.close

  Note.rng = Random.new

  define_method "gen_note_id" do
    Note.adj_list[Note.rng.rand(Note.adj_list.length)].titlecase + Note.noun_list[Note.rng.rand(Note.noun_list.length)].titlecase
  end
end
