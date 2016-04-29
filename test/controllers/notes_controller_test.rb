require 'test_helper'
require 'json'

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

  test "append to a note" do
    post :sync, {:unique_note_id => "GroovyGiraffe"}
    assert_response :success
    assert_select "html", "NullSync"


    sync_arr = [[18, "+ a feather in air"]]
    post :sync, {:unique_note_id => "GroovyGiraffe", :sync_json => sync_arr.to_json}
    assert_response :success
    assert_select "html", "Synced"
    n = assigns(:note)
    assert n.text == "Drifting away like a feather in air"

    sync_arr = [[1234, "9*)(*_#)(@84-0941-3"]]
    post :sync, {:unique_note_id => "GroovyGiraffe", :sync_json => sync_arr.to_json}
    
    # n = assigns :note
  end
end
