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
  end

  test "remove from a note" do
    sync_arr = [[19, "-11"]]
    post :sync, {:unique_note_id => "DeadDischord", :sync_json => sync_arr.to_json}
    assert_response :success
    assert_select "html", "Synced"

    n = assigns :note
    assert n.text == "I am sitting in the"

    sync_arr = [[19, "+ corner."]]
    post :sync, {:unique_note_id => "DeadDischord", :sync_json => sync_arr.to_json}

    n = assigns :note
    assert n.text == "I am sitting in the corner."
  end

  test "delete a note" do
    #Make sure the note exists
    assert Note.find_by_unique_note_id("GroovyGiraffe") != nil
    
    #Destroy the note
    delete :destroy, unique_note_id: "GroovyGiraffe"

    #Make sure we get the correct return status
    assert_response 302

    #Make sure the note is gone
    assert Note.find_by_unique_note_id("GroovyGiraffe") == nil
  end
  
  test "update a note" do
    post :update, {:unique_note_id => "DeadDischord", :time_til_death => "60"}
    assert_response :success
    assert_select "html", "NoteUpdated"
  end

  test "test locks" do
    get :index
    assert_response 302
    n = assigns(:note)
    assert_not_nil(n)
    assert n.is_locked == false

    post :create, {:unique_note_id => n.unique_note_id}
    
    sync_arr = [[0, "+drifting away like a feather in air..."]]
    post :sync, {:unique_note_id => n.unique_note_id, :sync_json => sync_arr.to_json}
    assert_response :success

    get :index, {:unique_note_id => n.unique_note_id}
    
    n = assigns(:note)
    assert_not_nil(n)
    assert n.is_locked == true

    assert n.time_til_death == 30
    post :update, {:unique_note_id => n.unique_note_id, :time_til_death => "60"}
    assert_select "html", "NoteLocked"
    n = assigns(:note)
    assert n.time_til_death == 30
  end
end
