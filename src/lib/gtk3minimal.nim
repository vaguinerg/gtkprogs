## gtk3minimal - Minimal GTK3 library for Nim
## 
## Contains only essential functions for basic interfaces:
## windows, buttons, labels, progress bars and basic layouts.

# =============================================================================
# BASIC GTK3 TYPES
# =============================================================================

type
  # Core widget types
  GtkWidget* = ptr object
  
  # Auxiliary types
  gboolean* = cint
  gint* = cint
  guint* = cuint
  gchar* = cchar
  gpointer* = pointer
  gdouble* = cdouble
  gfloat* = cfloat
  
  # Complete enums for available functions
  GtkOrientation* = enum
    GTK_ORIENTATION_HORIZONTAL = 0
    GTK_ORIENTATION_VERTICAL = 1
    
  GtkWindowType* = enum
    GTK_WINDOW_TOPLEVEL = 0
    GTK_WINDOW_POPUP = 1

# =============================================================================
# CONSTANTS AND COMPLETE ENUMS
# =============================================================================

const GTK_LIB = "libgtk-3.so.0"
const GLIB_LIB = "libgobject-2.0.so.0"

# Alignment constants (for gtk_widget_set_halign/valign)
const
  GTK_ALIGN_FILL* = 0
  GTK_ALIGN_START* = 1
  GTK_ALIGN_END* = 2
  GTK_ALIGN_CENTER* = 3
  GTK_ALIGN_BASELINE* = 4

# Window position constants (gtk_window_set_position)
const 
  GTK_WIN_POS_NONE* = 0
  GTK_WIN_POS_CENTER* = 1
  GTK_WIN_POS_MOUSE* = 2
  GTK_WIN_POS_CENTER_ALWAYS* = 3
  GTK_WIN_POS_CENTER_ON_PARENT* = 4

# Boolean values
const
  FALSE* = 0.gboolean
  TRUE* = 1.gboolean

# Signal connection flags
const
  G_CONNECT_AFTER* = 1.guint
  G_CONNECT_SWAPPED* = 2.guint

# Wrap mode constants for gtk_label_set_line_wrap_mode
const
  PANGO_WRAP_WORD* = 0
  PANGO_WRAP_CHAR* = 1  
  PANGO_WRAP_WORD_CHAR* = 2
  
# =============================================================================
# GTK3 CORE FUNCTIONS
# =============================================================================

# Initialization and main loop
proc gtk_init*(argc: ptr cint, argv: ptr ptr cstring) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_main*() {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_main_quit*() {.cdecl, importc, dynlib: GTK_LIB.}

# Widget basics
proc gtk_widget_show_all*(widget: GtkWidget) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_widget_destroy*(widget: GtkWidget) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_widget_set_sensitive*(widget: GtkWidget, sensitive: gboolean) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_widget_set_size_request*(widget: GtkWidget, width: gint, height: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_widget_set_halign*(widget: GtkWidget, align: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_widget_set_valign*(widget: GtkWidget, align: gint) {.cdecl, importc, dynlib: GTK_LIB.}

# Windows
proc gtk_window_new*(window_type: GtkWindowType): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_window_set_title*(window: GtkWidget, title: cstring) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_window_set_default_size*(window: GtkWidget, width: gint, height: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_window_set_resizable*(window: GtkWidget, resizable: gboolean) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_window_set_decorated*(window: GtkWidget, setting: gboolean) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_window_set_position*(window: GtkWidget, position: gint) {.cdecl, importc, dynlib: GTK_LIB.}

# Containers
proc gtk_container_add*(container: GtkWidget, widget: GtkWidget) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_container_set_border_width*(container: GtkWidget, border_width: guint) {.cdecl, importc, dynlib: GTK_LIB.}

# Box layout
proc gtk_box_new*(orientation: GtkOrientation, spacing: gint): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_box_pack_start*(box: GtkWidget, child: GtkWidget, expand: gboolean, fill: gboolean, padding: guint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_box_pack_end*(box: GtkWidget, child: GtkWidget, expand: gboolean, fill: gboolean, padding: guint) {.cdecl, importc, dynlib: GTK_LIB.}

# Fixed container
proc gtk_fixed_new*(): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_fixed_put*(fixed: GtkWidget, widget: GtkWidget, x: gint, y: gint) {.cdecl, importc, dynlib: GTK_LIB.}

# Buttons
proc gtk_button_new_with_label*(label: cstring): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}

# Labels
proc gtk_label_new*(str: cstring): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_text*(label: GtkWidget, str: cstring) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_line_wrap*(label: GtkWidget, wrap: gboolean) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_line_wrap_mode*(label: GtkWidget, wrap_mode: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_max_width_chars*(label: GtkWidget, n_chars: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_width_chars*(label: GtkWidget, n_chars: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_justify*(label: GtkWidget, jtype: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_ellipsize*(label: GtkWidget, mode: gint) {.cdecl, importc, dynlib: GTK_LIB.}

# Constants for label justification
const
  GTK_JUSTIFY_LEFT* = 0
  GTK_JUSTIFY_RIGHT* = 1
  GTK_JUSTIFY_CENTER* = 2
  GTK_JUSTIFY_FILL* = 3

# Constants for ellipsization
const
  PANGO_ELLIPSIZE_NONE* = 0
  PANGO_ELLIPSIZE_START* = 1
  PANGO_ELLIPSIZE_MIDDLE* = 2
  PANGO_ELLIPSIZE_END* = 3

# Progress bars
proc gtk_progress_bar_new*(): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_progress_bar_set_fraction*(pbar: GtkWidget, fraction: gdouble) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_progress_bar_set_text*(pbar: GtkWidget, text: cstring) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_progress_bar_set_show_text*(pbar: GtkWidget, show_text: gboolean) {.cdecl, importc, dynlib: GTK_LIB.}

# Signals
proc g_signal_connect_data*(instance: gpointer, detailed_signal: cstring, 
                           c_handler: pointer, data: gpointer, 
                           destroy_data: pointer, connect_flags: guint): culong {.
  cdecl, importc, dynlib: GLIB_LIB.}

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

proc g_signal_connect*(instance: gpointer, detailed_signal: cstring, 
                      c_handler: pointer, data: gpointer = nil): culong =
  g_signal_connect_data(instance, detailed_signal, c_handler, data, nil, 0)

proc gtk_init*() =
  var argc: cint = 0
  gtk_init(addr argc, nil)

# =============================================================================
# TEMPLATES
# =============================================================================

template connect*(widget: GtkWidget, signal: string, callback: untyped) =
  discard g_signal_connect(widget, signal.cstring, cast[pointer](callback))

template show*(widget: GtkWidget) =
  gtk_widget_show_all(widget)

template destroy*(widget: GtkWidget) =
  gtk_widget_destroy(widget)

template run*() =
  gtk_main()

template quit*() =
  gtk_main_quit()
