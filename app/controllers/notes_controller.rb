class NotesController < ApplicationController
  def index
    if(params[:unique_note_id] and Note.find_by_unique_note_id(params[:unique_note_id]) != nil) then
      # If the selected note id is taken then load the existing note object with that id
      # and display the view so we can edit the note
      @note = Note.find_by_unique_note_id(params[:unique_note_id])
    else
      # Create a new note with a blank id (that will fill in)
      @note = Note.new

      # Use the supplied id or generate a new id
      if(params[:unique_note_id]) then
        id_string = params[:unique_note_id]
      else
        id_string = @note.gen_note_id
        while(Note.find_by_unique_note_id(id_string) != nil) do
          id_string = @note.gen_note_id
        end

        # Redirect back to this same method
        # (so the id string shows up in the url)
        redirect_to "/" + id_string
      end
    end

    #Assign id string
    @note.unique_note_id = id_string
  end

  def create
    note = Note.new
    @note.unique_note_id = params.require(:unique_note_id)
    @note.save
    render :text => "NoteCreated"
  end
end
