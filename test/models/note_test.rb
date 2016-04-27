require 'test_helper'

class NoteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "the truth" do
    assert true
  end

  test "create note" do
    n = Note.new
    assert n.class == Note
    assert n.unique_note_id == ""
    assert n.text == ""

    print Note.new.gen_note_id
  end
  
  # test "create note" do
  #   n = Note.new()
  #   assert n.class() == Note
  #   n.unique_id_string = n.gen_note_id
  #   assert n.unique_id_string.length > 3
  #   assert n.unique_id_string.class.name == "String"
  #   print "id_string is: " + n.unique_id_string
  # end
end
