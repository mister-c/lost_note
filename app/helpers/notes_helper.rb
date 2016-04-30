module NotesHelper
  #For determining if we need to perform the create action
  def is_new_note(n)
    if(Note.find_by_unique_note_id(n.unique_note_id) != nil) then
      return false
    else
      return true
    end
  end
end
