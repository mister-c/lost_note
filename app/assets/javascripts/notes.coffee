# notes.coffee is the script that runs when a user is creating a new
# note or editing an old note.
#
# Either way its the same script
#
# Keeps track of all the insertions and deletions to the note using
# listeners. Stores those changes in a queue. Regularly submits those
# changes as POST requests to web server.
# 
##################################################




# Functions....
##################################################

# This event fires 3 seconds after the user last input some text
# 
# This function will lock itself so that if the additional
# stuff gets added to the queue... it wont get synced until
# the precending event finishes resolving
queue_sync_event = ->
        # console.log("queue sync event")

        # Get the Document ID so we can submit our data to the right
        # url and stuff....
        unique_note_id = window.location.pathname.substr(1)

        # Lock the note box so no other post requests get sent ahead
        # of this one
        n = document.getElementById("note_box")
        n.is_locked = true

        if n.queue.toString().length > 100 or (Date.now() - n.timer > (1000 * 5) and n.queue.length > 0)
                # console.log("generating sync event...")
                x = new XMLHttpRequest()
                                        
                # If we're caught up...
                # wait a little while and check the queue again
                x.onreadystatechange = ->
                        if x.readyState == 4 and x.status == 200
                                n = document.getElementById("note_box")
                                s = document.getElementById("save_status")
                                n.is_locked = false
                                if n.queue.length == 0
                                        s.innerHTML = "Saved"
                                # console.log("submitted sync event")

                # Submit the data
                ##################################################
                # console.log("POST string...")
                # console.log("unique_note_id=" + unique_note_id + "&sync_json=" + encodeURIComponent(queue_string) +
                #    "&authenticity_token=" + encodeURIComponent(AUTH_TOKEN))
                queue_string = JSON.stringify(n.queue)
                x.open("POST", "sync", true)
                x.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
                x.send("unique_note_id=" + unique_note_id + "&sync_json=" + encodeURIComponent(queue_string) +
                   "&authenticity_token=" + encodeURIComponent(AUTH_TOKEN))
                #Empty the queue 
                n.queue = []

# This event fires the first time a user inputs text
# into a new document.
#
# Once the document is created this event never fires again
creation_listener = (n) ->
        # console.log("Creating note!")

        # Turn off the creation_listener
        # so this event doesn't run multiple times
        document.getElementById("note_box").oninput = null

        #Get the unique_note_id from the pathname
        unique_note_id = window.location.pathname.substr(1)
        # console.log("Unique id string is..." + unique_note_id)
        
        x = new XMLHttpRequest()
        x.onreadystatechange = ->
                # Once the POST request completes... add all the listeners so we
                # can start synchronizing the note
                if x.readyState == 4 and x.status == 200
                        # console.log("ajax complete")
                        n = document.getElementById("note_box")
                        n.onselect = select_listener
                        n.oninput = update_listener
                        n.onkeydown = deselect_listener
                        n.onclick = deselect_listener
                        update_listener()

        # OK lets submit the create event as a POST request. Awww yeah.
        x.open("POST", "create", true)
        x.setRequestHeader("Content-type", "application/x-www-form-urlencoded")
        x.send("unique_note_id=" + unique_note_id + "&authenticity_token=" + encodeURIComponent(AUTH_TOKEN))


# This is where the bulk of the code happens. This is also where the lag happens...
# First, it adjusts for any text selection... since its possible to delete and
# insert text with a single key stroke if you have any text selected
#
# Next, detects if text was inserted or deleted and puts the new changes in a queue
# structure
#
# Last, it sets a timer so 3 seconds from the users last key stroke, a POST request
# is sent to the server containing the JSON encoded version of the queue
update_listener = ->
        # console.log("new input detected! Fuck yeah!")

        # Get elements from the page so we can do stuff
        n = document.getElementById("note_box")
        s = document.getElementById("save_status")

        # console.log("was there a selection? " + (n.select_bound[1] > n.select_bound[0]))
        # console.log("selection size?" + n.select_bound[1] - n.select_bound[0])

        # If the user inputs a new character while something is selected it will
        # perform a compound delete+insert
        if n.select_bound[1] > n.select_bound[0]
                num_del_char = n.select_bound[1] - n.select_bound[0]
                n.queue.push([n.select_bound[0], "-" + num_del_char])
                n.note_length -= num_del_char

        # Restarts the sync timer. This way... the sync happens three seconds after
        # the users last key stroke. If typing a long sentence, it will wait for
        # the user to finish typing before sending the POST request
        if n.queue.toString().length > 150 and not n.is_locked
                clearTimeout(n.timer)
                queue_sync_event()

        #Store the length so we dont have to recalculate it over and over
        nvl = n.value.length
        nql = n.queue.length
        
        # Check if its a deletion or insertion
        # If its an insertion... either add a new append node or keep adding characters
        # to the previous node in the queue
        # If its a deletion..... either add a new deletion node or increase the number
        # of deleted characters by one and adjust the deletion index 
        if nvl > n.note_length
                # This avoids a -1 insertion_pos value... perhaps there's a better way?
                if n.selectionStart > 0
                        insertion_pos = n.selectionStart - (nvl - n.note_length)
                else
                        insertion_pos = 0

                # Checks conditions for creating a new node then adds characters to the node
                if nql < 1 or n.selectionStart != n.cursor_pos + 1 or n.queue[nql-1][1][0] != "+"
                        n.queue.push([insertion_pos, "+"])
                        nql = n.queue.length
                        # console.log("Creating a new append node")
                n.queue[nql-1][1] += n.value.slice(insertion_pos, n.selectionStart)
                # console.log("append length: " + (nvl - n.note_length))
                # console.log("appending..." + n.value.slice(insertion_pos, n.selectionStart))
                # console.log(n.queue[n.queue.length-1][1])
        else if nvl < n.note_length
                # Checks conditions for creating a new node and then increments the deletion cound
                if n.queue.length < 1 or n.selectionStart != n.cursor_pos - 1 or n.queue[nql-1][1][0] != "-"
                        n.queue.push([n.selectionStart, "-0"])
                        nql = n.queue.length
                        # console.log("Creating a new delete node")
                # Need to adjust index so the node contains the smallest index of the deleted characters
                n.queue[nql-1][0] = n.selectionStart
                n.queue[nql-1][1] = "-" + (parseInt(n.queue[nql-1][1].slice(1)) + n.note_length - nvl).toString()
                # console.log(n.queue[n.queue.length-1][1])
                #The user deleted something

        #Don't re-enble this or this script will lag like a bitch
        # console.log("queue..." + n.queue.toString())

        # Update these attributes for the note box
        n.cursor_pos = n.selectionStart
        n.note_length = nvl

        # Update save status and start a timer to synchronize the note
        s.innerHTML = "Not saved"
        clearTimeout(n.timer)
        n.timer = setTimeout( (() ->
                n = document.getElementById("note_box")
                if(not n.is_locked)
                        clearTimeout(n.timer)
                        queue_sync_event()
                ), 3000)

# This event fires if text was selected. Updates the selection attribute
select_listener = ->
        n = document.getElementById("note_box")
        if n.selectionStart < n.selectionEnd
                # console.log("Something was selected!")
                n.select_bound[0] = n.selectionStart
                n.select_bound[1] = n.selectionEnd

# This event fires if the user clicks or presses a key. Resets selection
# status. Kind of a hack, since there is no "deselection" event
deselect_listener = ->
        n = document.getElementById("note_box")
        if (n.select_bound[1] > n.select_bound[0]) and n.selectionStart == n.selectionEnd and n.value.length == n.note_length
                # console.log("Something was deselected...")
                n.select_bound[0] = n.selectionStart
                n.select_bound[1] = n.selectionEnd

# End of functions
##################################################




# The document loaded event listener
# This is where the code starts...
document.addEventListener("DOMContentLoaded", (event) ->
        # console.log("Document loaded!!")

        current_url = window.location.href
        document.getElementById("note_full_url").innerHTML = current_url

        n_box = document.getElementById("note_box")
        # console.log "is newtype?..." + n_box.getAttribute("data-newtype")

        # Set all the instance variables for the note box
        # These attributes track whats selected and inserted
        # in the textarea
        n_box.queue      = []
        n_box.cursor_pos = -1
        n_box.is_locked  = false
        n_box.select_bound = [0, 0]
        n_box.note_length  = n_box.value.length
        # Determine if this is an existing note or a new one
        if n_box.getAttribute("data-newtype") == "true"
                # console.log("new note bitches")
                n_box.oninput = creation_listener
        else
                #Create listeners for changes to the note
                n_box.onselect = select_listener
                n_box.oninput = update_listener
                n_box.onkeydown = deselect_listener
                n_box.onclick = deselect_listener
)
