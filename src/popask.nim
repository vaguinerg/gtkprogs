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
  window.gtk_window_set_resizable(FALSE)
  window.gtk_window_set_default_size(300, 150)
  window.gtk_container_set_border_width(10)
  
  let box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 10)  # spacing 10px
  window.gtk_container_add(box)
  
  if message.len > 0:
    let label = gtk_label_new(message.cstring)
    label.gtk_label_set_line_wrap(TRUE)
    label.gtk_label_set_justify(GTK_JUSTIFY_CENTER)
    box.gtk_box_pack_start(label, TRUE, TRUE, 10)
  
  let buttons = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10)
  buttons.gtk_widget_set_halign(GTK_ALIGN_CENTER)  # Centraliza horizontalmente
  box.gtk_box_pack_end(buttons, FALSE, FALSE, 10)
  
  let no = gtk_button_new_with_label(gettext("No"))
  let yes = gtk_button_new_with_label(gettext("Yes"))
  no.gtk_widget_set_size_request(90, 35)
  yes.gtk_widget_set_size_request(90, 35)
  buttons.gtk_box_pack_start(yes, FALSE, FALSE, 0)  # Primeiro botão
  buttons.gtk_box_pack_start(no, FALSE, FALSE, 10)  # Segundo botão com 10px de espaço
  
  window.connect("destroy", on_destroy)
  no.connect("clicked", on_no_clicked)
  yes.connect("clicked", on_yes_clicked)
  
  window.show()
  run()
  echo response

when isMainModule:
  main()
