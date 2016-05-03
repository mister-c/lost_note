class NotesController < ApplicationController
  # Index does 1 of 2 things
  #   opens a blank note and picks a random id string
  #   opens an existing note and allows you to edit it
  ##################################################
  def index
    # If there is an id provided that belongs to an existing note... then load that note
    # Otherwise open a blank note
    if(params[:unique_note_id] and Note.find_by_unique_note_id(params[:unique_note_id]) != nil) then
      # If the selected note id is taken then load the existing note object with that id
      # and display the view so we can edit the note
      @note = Note.find_by_unique_note_id(params[:unique_note_id])
    else
      # Create a new note with a blank id (that will fill in)
      # This note is NOT inserted into the database yet
      @note = Note.new

      # Use the supplied id or generate a new id
      if(params[:unique_note_id]) then
        id_string = params[:unique_note_id]
      else
        #Generate an id and make sure it is unique
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

  # Create a new note with the supplied note_id and insert
  # it in the database
  ##################################################
  def create
    @note = Note.new
    @note.unique_note_id = params.require(:unique_note_id)
    @note.save
    render :text => "NoteCreated"
  end

  # Update attributes of the note
  # ONLY allows you to update time_til_death and reads_til_death
  # if you want to update the text, use the sync action
  ##################################################
  def update
    @note = Note.find(update_params[:unique_note_id])
    #check params to see which field is being updated
  end

  # Delete the note with the given note_id
  # Used by the lil trash icon
  ##################################################
  def destroy
    @note = Note.find_by_unique_note_id(params.require(:unique_note_id))
    if(@note != nil) then
      @note.delete
    end
    redirect_to root_path
  end

  # Receives a JSON array of appends and removals...
  # Parses and applies those appends + removals to the
  # note text
  ##################################################
  def sync
    # Find the given note id
    @note = Note.find_by_unique_note_id(sync_params[:unique_note_id])
    if(@note == nil) then
      render :text => "NotFound"
      return
    end

    # If there is a JSON array given... then for each element
    # of the array either append or remove the given text
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

  def update_params
    params.require(:unique_note_id, :time_til_death)
    params
  end

  def append(start_index, str)
    @note.text.insert(start_index, str)
  end

  def remove(start_index, num_del)
    @note.text.slice!(start_index, num_del)
  end
end
