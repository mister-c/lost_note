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
      #Assign id string
      @note.unique_note_id = id_string
    end
  end

  def create
    @note = Note.new
    @note.unique_note_id = params.require(:unique_note_id)
    @note.save
    render :text => "NoteCreated"
  end

  def sync
    @note = Note.find_by_unique_note_id(sync_params[:unique_note_id])
    if(@note == nil) then
      render :text => "NotFound"
      return
    end
    
    if(!sync_params[:sync_json]) then
      render :text => "NullSync"
    else
      arr = JSON.parse(sync_params[:sync_json])
      arr.each do |t|
        if(t[1] =~ /^\+/) then
          append(t[0], t[1][1..-1])
        elsif(t[1] =~ /^\-/) then
          remove(t[0], t[1][1..-1].to_i)
        end
      end
      @note.save
      render :text => "Synced"
    end
  end

  private
  def sync_params
    params.require(:unique_note_id)
    params
  end

  def append(start_index, str)
    @note.text.insert(start_index, str)
  end

  def remove(start_index, num_del)
    @note.text.slice!(start_index, num_del)
  end
end
