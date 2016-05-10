class Note < ActiveRecord::Base
  validates :unique_note_id, presence: true
  validates :unique_note_id, uniqueness: true
  validates :unique_note_id, length: { maximum: 80 }
  validates :text, length: { maximum: 297_000 }
  validates :time_til_death, presence: true
  validates :time_til_death, inclusion: {in: [30, 60, 1440, 10080, -1]}
  validates :max_num_read, presence: true
  validates :max_num_read, inclusion: {in: (-1..10).to_a}
  # validates :max_num_read, {maximum: 10, minimum: -1}
  # validates :max_num_read, inclusion: {in: [1, 3, 10, -1]}
  
  class_attribute :adj_list
  class_attribute :noun_list
  class_attribute :rng

  adj_file  = open("lib/assets/simple_adj.txt")
  noun_file = open("lib/assets/simple_noun.txt")
  Note.adj_list = adj_file.read.split("\n")
  adj_file.close
  Note.noun_list = noun_file.read.split("\n")
  noun_file.close

  Note.rng = Random.new

  define_method "gen_note_id" do
    Note.adj_list[Note.rng.rand(Note.adj_list.length)].titlecase + Note.noun_list[Note.rng.rand(Note.noun_list.length)].titlecase
  end
end
