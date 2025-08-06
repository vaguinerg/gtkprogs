import lib/[gettext, gtk3minimal]
import os, strutils, osproc, sequtils, algorithm

initGettext("tinycore", "/usr/local/share/locale")

var
  window: GtkWidget
  command_combo: GtkWidget
  sudo_check: GtkWidget

const HISTORY_FILE = getHomeDir() / ".ash_history"

proc saveCommand(cmd: string) =
  let entry = "[gtkrun]" & cmd & "\n"
  let f = open(HISTORY_FILE, fmAppend)
  try:
    f.write(entry)
  finally:
    f.close()

proc loadHistory(): seq[string] =
  if not fileExists(HISTORY_FILE): return @[]
  result = readFile(HISTORY_FILE)
    .splitLines()
    .filterIt(it.startsWith("[gtkrun]"))
    .mapIt(it.replace("[gtkrun]", ""))
    .deduplicate()
    .reversed()

proc getCurrentCommand(): string =
  let entry = gtk_bin_get_child(command_combo)
  return $gtk_entry_get_text(entry)

proc setCurrentCommand(cmd: string) =
  let entry = gtk_bin_get_child(command_combo)
  gtk_entry_set_text(entry, cmd.cstring)

proc executeCommand() =
  let cmdText = getCurrentCommand().strip()
  if cmdText.len == 0: return
  
  saveCommand(cmdText)  # Save original command
  
  var cmd = cmdText
  if gtk_toggle_button_get_active(sudo_check).bool:
    cmd = "sudo " & cmd
    
  discard execCmd(cmd & " 2>/dev/null &")
  gtk3minimal.quit()

proc on_ok_clicked(widget: GtkWidget, data: gpointer) {.cdecl.} =
  executeCommand()

proc on_cancel_clicked(widget: GtkWidget, data: gpointer) {.cdecl.} =
  gtk3minimal.quit()

proc on_browse_clicked(widget: GtkWidget, data: gpointer) {.cdecl.} =
  let dialog = gtk_file_chooser_dialog_new(
    gettext("Choose File"),
    window,
    GTK_FILE_CHOOSER_ACTION_OPEN,
    gettext("Cancel"),
    GTK_RESPONSE_CANCEL,
    gettext("Open"),
    GTK_RESPONSE_ACCEPT)

  let response = gtk_dialog_run(dialog)
  if response == GTK_RESPONSE_ACCEPT:
    let filename = gtk_file_chooser_get_filename(dialog)
    setCurrentCommand($filename)
  
  dialog.destroy()

proc on_window_destroy(widget: GtkWidget, data: gpointer) {.cdecl.} =
  gtk3minimal.quit()

proc on_entry_activate(widget: GtkWidget, data: gpointer) {.cdecl.} =
  executeCommand()

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

# ComboBox with text entry (instead of simple entry)
command_combo = gtk_combo_box_text_new_with_entry()
box.gtk_box_pack_start(command_combo, FALSE, FALSE, 0)

# Populate combo box with history
let history = loadHistory()
for cmd in history:
  if cmd.len > 0:
    gtk_combo_box_text_append_text(command_combo, cmd.cstring)

# Get the entry widget from combo box to connect Enter key
let combo_entry = gtk_bin_get_child(command_combo)
combo_entry.connect("activate", on_entry_activate)

# Sudo checkbox
sudo_check = gtk_check_button_new_with_label(gettext("Run with sudo"))
box.gtk_box_pack_start(sudo_check, FALSE, FALSE, 0)

# Button box
let buttons = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10)
buttons.gtk_widget_set_halign(GTK_ALIGN_CENTER)
box.gtk_box_pack_end(buttons, FALSE, FALSE, 0)

# Buttons (removed history button)
let 
  ok_button = gtk_button_new_with_label(gettext("OK"))
  cancel_button = gtk_button_new_with_label(gettext("Cancel"))
  browse_button = gtk_button_new_with_label(gettext("Browse"))

for btn in [ok_button, cancel_button, browse_button]:
  btn.gtk_widget_set_size_request(90, 35)
  buttons.gtk_box_pack_start(btn, FALSE, FALSE, 0)

# Connect signals
window.connect("destroy", on_window_destroy)
ok_button.connect("clicked", on_ok_clicked)
cancel_button.connect("clicked", on_cancel_clicked)
browse_button.connect("clicked", on_browse_clicked)

window.show()
run()