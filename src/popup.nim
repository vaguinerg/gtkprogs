import lib/[gettext, gtk3minimal]
import os, strutils

initGettext("tinycore", "/usr/local/share/locale")

proc on_close_clicked(widget: GtkWidget, data: gpointer) {.cdecl.} =
  gtk3minimal.quit()

proc main() =
  let message = commandLineParams().join(" ")
  gtk_init()
  
  let window = gtk_window_new(GTK_WINDOW_TOPLEVEL)
  window.gtk_window_set_title(gettext("Message"))
  window.gtk_container_set_border_width(10)
  window.gtk_window_set_resizable(FALSE)
  window.gtk_window_set_default_size(300, 150)
  
  let box = gtk_box_new(GTK_ORIENTATION_VERTICAL, 10)
  window.gtk_container_add(box)
  
  let label = gtk_label_new(message.cstring)
  label.gtk_label_set_line_wrap(TRUE)
  box.gtk_box_pack_start(label, TRUE, TRUE, 0)
  
  let button = gtk_button_new_with_label(gettext("Close"))
  box.gtk_box_pack_start(button, FALSE, FALSE, 0)
  
  window.connect("destroy", on_close_clicked)
  button.connect("clicked", on_close_clicked)
  
  window.show()
  run()

when isMainModule:
  main()
