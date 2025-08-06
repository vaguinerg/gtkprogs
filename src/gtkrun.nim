import lib/[gettext, gtk3minimal]
import os, strutils, osproc, algorithm, sequtils, strformat

initGettext("tinycore", "/usr/local/share/locale")

# =============================================================================
# GLOBALS
# =============================================================================

var
  window: GtkWidget
  command_entry: GtkWidget
  command_list: GtkWidget
  sudo_check: GtkWidget

# =============================================================================
# PROGRAM FUNCTIONS
# =============================================================================

proc findExecutables(search: string): seq[string] =
  result = @[]
  if search.len == 0: return
  
  for path in getEnv("PATH").split(':'):
    if not dirExists(path): continue
    
    for kind, file in walkDir(path):
      if (kind in {pcFile, pcLinkToFile}) and 
         (search.len == 0 or file.extractFilename.toLowerAscii.contains(search.toLowerAscii)):
        result.add(file.extractFilename)
  
  result.sort(Descending)
  result = result.deduplicate()

proc executeCommand() =
  let cmdText = $gtk_entry_get_text(command_entry)  # Convert cstring to string first
  var cmd = cmdText.strip()
  if cmd.len == 0: return
  
  if gtk_toggle_button_get_active(sudo_check).bool:
    cmd = "sudo " & cmd
    
  discard execCmd(cmd & " 2>/dev/null &")
  gtk3minimal.quit()

# =============================================================================
# CALLBACKS
# =============================================================================

proc on_ok_clicked(widget: GtkWidget, data: gpointer) {.cdecl.} =
  executeCommand()

proc on_cancel_clicked(widget: GtkWidget, data: gpointer) {.cdecl.} =
  gtk3minimal.quit()

proc on_browse_clicked(widget: GtkWidget, data: gpointer) {.cdecl.} =
  # TODO: Implement file chooser when available in gtk3minimal
  discard

proc on_entry_changed(widget: GtkWidget, data: gpointer) {.cdecl.} =
  let search = gtk_entry_get_text(command_entry)
  gtk_list_store_clear(command_list)
  
  for exec in findExecutables($search):
    gtk_list_store_append(command_list, exec.cstring)

proc on_window_destroy(widget: GtkWidget, data: gpointer) {.cdecl.} =
  gtk3minimal.quit()

# =============================================================================
# GTK3 CORE FUNCTIONS
# =============================================================================

gtk_init()

# Main Window
window = gtk_window_new(GTK_WINDOW_TOPLEVEL)
window.gtk_window_set_title(gettext("GTK Run"))
window.gtk_window_set_default_size(265, 125)
window.gtk_window_set_resizable(FALSE)
window.gtk_container_set_border_width(10)

# Main vertical box
let box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 10)
window.gtk_container_add(box)

# Entry with completion
command_entry = gtk_entry_new()
command_list = gtk_list_store_new()
let completion = gtk_entry_completion_new()
gtk_entry_set_completion(command_entry, completion)
gtk_entry_completion_set_model(completion, command_list)
gtk_entry_completion_set_text_column(completion, 0)

box.gtk_box_pack_start(command_entry, FALSE, FALSE, 0)

# Sudo checkbox
sudo_check = gtk_check_button_new_with_label(gettext("Run with sudo"))
box.gtk_box_pack_start(sudo_check, FALSE, FALSE, 0)

# Button box
let buttons = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10)
buttons.gtk_widget_set_halign(GTK_ALIGN_CENTER)
box.gtk_box_pack_end(buttons, FALSE, FALSE, 0)

# OK button
let ok_button = gtk_button_new_with_label(gettext("OK"))
ok_button.gtk_widget_set_size_request(90, 35)

# Cancel button
let cancel_button = gtk_button_new_with_label(gettext("Cancel"))
cancel_button.gtk_widget_set_size_request(90, 35)

# Browse button
let browse_button = gtk_button_new_with_label(gettext("Browse"))
browse_button.gtk_widget_set_size_request(90, 35)

buttons.gtk_box_pack_start(ok_button, FALSE, FALSE, 0)
buttons.gtk_box_pack_start(cancel_button, FALSE, FALSE, 0)
buttons.gtk_box_pack_start(browse_button, FALSE, FALSE, 0)

# Connect signals
window.connect("destroy", on_window_destroy)
ok_button.connect("clicked", on_ok_clicked)
cancel_button.connect("clicked", on_cancel_clicked)
browse_button.connect("clicked", on_browse_clicked)
command_entry.connect("changed", on_entry_changed)

window.show()
run()
