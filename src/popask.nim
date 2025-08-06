import lib/[gettext, gtk3minimal]
import os, strutils

initGettext("tinycore", "/usr/local/share/locale")

var response = 0

proc on_no_clicked(widget: GtkWidget, data: gpointer) {.cdecl.} =
  response = 0
  gtk3minimal.quit()

proc on_yes_clicked(widget: GtkWidget, data: gpointer) {.cdecl.} =
  response = 1
  gtk3minimal.quit()

proc on_destroy(widget: GtkWidget, data: gpointer) {.cdecl.} =
  gtk3minimal.quit()

proc main() =
  let message = commandLineParams().join(" ")

  gtk_init()
  
  let window = gtk_window_new(GTK_WINDOW_TOPLEVEL)
  window.gtk_window_set_title(gettext("Question"))
  window.gtk_container_set_border_width(10)
  window.gtk_window_set_resizable(FALSE)
  window.gtk_window_set_default_size(300, 150)
  
  let box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 10)
  window.gtk_container_add(box)
  
  if message.len > 0:
    let label = gtk_label_new(message.cstring)
    label.gtk_label_set_line_wrap(TRUE)
    box.gtk_box_pack_start(label, TRUE, TRUE, 0)
  
  let buttonBox = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10)
  box.gtk_box_pack_start(buttonBox, FALSE, FALSE, 0)
  
  let noButton = gtk_button_new_with_label(gettext("No"))
  let yesButton = gtk_button_new_with_label($gettext("Yes"))
  buttonBox.gtk_box_pack_end(noButton, FALSE, FALSE, 0)
  buttonBox.gtk_box_pack_end(yesButton, FALSE, FALSE, 0)
  
  window.connect("destroy", on_destroy)
  noButton.connect("clicked", on_no_clicked)
  yesButton.connect("clicked", on_yes_clicked)
  
  window.show()
  run()
  echo response

when isMainModule:
  main()
