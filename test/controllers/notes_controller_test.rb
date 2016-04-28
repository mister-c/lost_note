require 'test_helper'

class NotesControllerTest < ActionController::TestCase
  test "the truth" do
    assert true
  end

  test "note creation" do
    get :index
    assert_response 302
    assert_not_nil assigns(:note)
    assert_not_nil assigns(:note).unique_note_id

    note_id = assigns(:note).unique_note_id
    printf note_id

    post :create, {:unique_note_id => note_id}
    assert_not_nil assigns(:note)
  end
end
