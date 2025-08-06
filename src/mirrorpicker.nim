import lib/[gettext, gtk3minimal]
import os, sequtils, strformat, strutils, times, osproc, uri

initGettext("tinycore", "/usr/local/share/locale")

# =============================================================================
# GLOBALS
# =============================================================================

const 
  mirrorListFile: string = "/usr/local/share/mirrors"
  downloadFileRemotePath = "/15.x/x86/tcz/info.lst.gz"
  downloadFileMD5 = "94679869544f60a9473dd3daf38206f2"
  downloadFileTimeout = 10

var 
  logicThread: Thread[void]
  window: GtkWidget
  status_label: GtkWidget
  progress_bar: GtkWidget
  ok_button: GtkWidget
  fastest_mirror: string

# =============================================================================
# CALLBACKS
# =============================================================================

proc on_ok_clicked(widget: GtkWidget, data: gpointer) {.cdecl.} =
  try:
    writeFile("/opt/tcemirror", fastest_mirror)
    gtk3minimal.quit()
  except IOError:
    gtk_label_set_text(status_label, gettext("Error: Could not write to /opt/tcemirror"))

proc on_cancel_clicked(widget: GtkWidget, data: gpointer) {.cdecl.} =
  gtk3minimal.quit()

proc on_window_destroy(widget: GtkWidget, data: gpointer) {.cdecl.} =
  gtk3minimal.quit()

# =============================================================================
# PROGRAM FUNCTIONS
# =============================================================================

proc loadMirrors(): seq[string] =
  if not fileExists(mirrorListFile):
    discard execShellCmd("tce-load -il mirrors.tcz")
  if not fileExists(mirrorListFile):
    discard execShellCmd("tce-load -wil mirrors.tcz")
  if not fileExists(mirrorListFile):
    return @[]
  toSeq(lines(mirrorListFile)).filterIt(it.strip() != "")

proc testMirror(mirror: string): tuple[isValid: bool, timeMs: int64] =
  let startTime = getTime()
  let cmd = fmt"busybox wget -qO- --timeout={downloadFileTimeout} {mirror}{downloadFileRemotePath} | busybox md5sum"
  let (output, exitCode) = execCmdEx(cmd)
  let endTime = getTime()
  let duration = (endTime - startTime).inMilliseconds
  
  if exitCode == 0:
    let hash = output.split()[0]  # Get first word (the md5)
    return (hash == downloadFileMD5, duration)
  return (false, 0)

# =============================================================================
# LOGIC THREAD
# =============================================================================

proc logicFunction() =
  {.cast(gcsafe).}:
    let mirrors = loadMirrors()
    if mirrors.len < 1:
      gtk_label_set_text(status_label, gettext("Couldn't load mirror list. Maybe network issue?"))
      return
    
    let translatedText = $gettext("Checking %u mirrors, please wait...")
    gtk_label_set_text(status_label, (translatedText.replace("%u", $mirrors.len)).cstring)
    
    var progress = 0.0
    let progressStep = 1.0 / mirrors.len.float
    var fastest_time = high(int64)
    
    for mirror in mirrors:
      gtk_progress_bar_set_text(progress_bar, parseUri(mirror).hostname.cstring)
      let (isValid, timeMs) = testMirror(mirror)
      
      if isValid and timeMs < fastest_time:
        fastest_time = timeMs
        fastest_mirror = mirror
      
      progress += progressStep
      gtk_progress_bar_set_fraction(progress_bar, progress)
    
    gtk_progress_bar_set_fraction(progress_bar, 100.0)
    if fastest_mirror != "":
      let status = fmt"{parseUri(fastest_mirror).hostname} {fastest_time}ms"
      gtk_progress_bar_set_text(progress_bar, status.cstring)
      let resultText = $gettext("The fastest mirror was %.*s. Press ok to set it as your mirror.")
      gtk_label_set_text(status_label, resultText.replace("%.*s", parseUri(fastest_mirror).hostname).cstring)
      ok_button.gtk_widget_set_sensitive(TRUE)
    else:
      gtk_label_set_text(status_label, gettext("No valid mirrors found"))

# =============================================================================
# GTK3 CORE FUNCTIONS
# =============================================================================

# Start GTK
gtk_init()

# Main Window
window = gtk_window_new(GTK_WINDOW_TOPLEVEL)
window.gtk_window_set_title(gettext("Mirror picker"))
window.gtk_window_set_default_size(300, 150)
window.gtk_window_set_resizable(FALSE)
window.gtk_container_set_border_width(10)
window.gtk_window_set_decorated(FALSE)

# Vertical box como container principal
let box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 10)
window.gtk_container_add(box)

# Progress bar
progress_bar = gtk_progress_bar_new()
progress_bar.gtk_widget_set_size_request(250, 25)
progress_bar.gtk_progress_bar_set_show_text(TRUE)
box.gtk_box_pack_start(progress_bar, FALSE, FALSE, 0)

# Status text
status_label = gtk_label_new(gettext("Loading mirror list"))
status_label.gtk_label_set_line_wrap(TRUE)
status_label.gtk_label_set_line_wrap_mode(PANGO_WRAP_WORD)
status_label.gtk_label_set_max_width_chars(30)  # Limita largura do texto
status_label.gtk_label_set_width_chars(30)      # Força largura fixa
status_label.gtk_widget_set_size_request(250, 45)
status_label.gtk_label_set_justify(GTK_JUSTIFY_CENTER)
status_label.gtk_widget_set_halign(GTK_ALIGN_CENTER)
status_label.gtk_widget_set_valign(GTK_ALIGN_START)
box.gtk_box_pack_start(status_label, TRUE, TRUE, 0)

# Box para os botões
let buttons = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10)
buttons.gtk_widget_set_halign(GTK_ALIGN_CENTER)
box.gtk_box_pack_end(buttons, FALSE, FALSE, 10)

# OK button
ok_button = gtk_button_new_with_label(gettext("OK"))
ok_button.gtk_widget_set_size_request(90, 35)
ok_button.gtk_widget_set_sensitive(FALSE)

# Cancel button
let cancel_button = gtk_button_new_with_label(gettext("Cancel"))
cancel_button.gtk_widget_set_size_request(90, 35)

# Adiciona botões na ordem correta
buttons.gtk_box_pack_start(ok_button, FALSE, FALSE, 0)
buttons.gtk_box_pack_start(cancel_button, FALSE, FALSE, 10)

# Connect signals
window.connect("destroy", on_window_destroy)
ok_button.connect("clicked", on_ok_clicked)
cancel_button.connect("clicked", on_cancel_clicked)

# Show the window
window.show()

# Start logic thread
createThread(logicThread, logicFunction)

run()
