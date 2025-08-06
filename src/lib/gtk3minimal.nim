## gtk3minimal - Minimal GTK3 library for Nim
## Contains only essential functions for basic interfaces

# =============================================================================
# CONSTANTS AND LIBRARY IMPORTS
# =============================================================================

const GTK_LIB = "libgtk-3.so.0"
const GLIB_LIB = "libgobject-2.0.so.0"

# =============================================================================
# BASIC TYPES
# =============================================================================

type
  # Core widget types
  GtkWidget* = ptr object
  GtkListStore* = ptr object
  GdkEvent* = ptr object
  
  # Auxiliary types
  gboolean* = cint
  gint* = cint
  guint* = cuint
  guint64* = uint64
  gulong* = culong
  gchar* = cchar
  gpointer* = pointer
  gdouble* = cdouble
  gfloat* = cfloat
  gsize* = culong

# =============================================================================
# ENUMERATIONS
# =============================================================================

type
  GtkOrientation* = enum
    GTK_ORIENTATION_HORIZONTAL = 0
    GTK_ORIENTATION_VERTICAL = 1
    
  GtkWindowType* = enum
    GTK_WINDOW_TOPLEVEL = 0
    GTK_WINDOW_POPUP = 1
    
  GtkFileChooserAction* = enum
    GTK_FILE_CHOOSER_ACTION_OPEN = 0
    GTK_FILE_CHOOSER_ACTION_SAVE = 1
    GTK_FILE_CHOOSER_ACTION_SELECT_FOLDER = 2
    GTK_FILE_CHOOSER_ACTION_CREATE_FOLDER = 3
    
  GdkGravity* = enum
    GDK_GRAVITY_NORTH_WEST = 1
    GDK_GRAVITY_NORTH = 2
    GDK_GRAVITY_NORTH_EAST = 3
    GDK_GRAVITY_WEST = 4
    GDK_GRAVITY_CENTER = 5
    GDK_GRAVITY_EAST = 6
    GDK_GRAVITY_SOUTH_WEST = 7
    GDK_GRAVITY_SOUTH = 8
    GDK_GRAVITY_SOUTH_EAST = 9
    GDK_GRAVITY_STATIC = 10

# =============================================================================
# CONSTANTS
# =============================================================================

# Boolean values
const
  FALSE* = 0.gboolean
  TRUE* = 1.gboolean

# Alignment constants
const
  GTK_ALIGN_FILL* = 0
  GTK_ALIGN_START* = 1
  GTK_ALIGN_END* = 2
  GTK_ALIGN_CENTER* = 3
  GTK_ALIGN_BASELINE* = 4

# Window position constants
const 
  GTK_WIN_POS_NONE* = 0
  GTK_WIN_POS_CENTER* = 1
  GTK_WIN_POS_MOUSE* = 2
  GTK_WIN_POS_CENTER_ALWAYS* = 3
  GTK_WIN_POS_CENTER_ON_PARENT* = 4

# Signal connection flags
const
  G_CONNECT_AFTER* = 1.guint
  G_CONNECT_SWAPPED* = 2.guint

# Dialog response constants
const
  GTK_RESPONSE_ACCEPT* = -3
  GTK_RESPONSE_CANCEL* = -6

# Label justification constants
const
  GTK_JUSTIFY_LEFT* = 0
  GTK_JUSTIFY_RIGHT* = 1
  GTK_JUSTIFY_CENTER* = 2
  GTK_JUSTIFY_FILL* = 3

# Ellipsization constants
const
  PANGO_ELLIPSIZE_NONE* = 0
  PANGO_ELLIPSIZE_START* = 1
  PANGO_ELLIPSIZE_MIDDLE* = 2
  PANGO_ELLIPSIZE_END* = 3

# Wrap mode constants
const
  PANGO_WRAP_WORD* = 0
  PANGO_WRAP_CHAR* = 1  
  PANGO_WRAP_WORD_CHAR* = 2

# GObject type system constants
const
  G_TYPE_STRING* = 16
  G_TYPE_FUNDAMENTAL_SHIFT* = 2
  G_TYPE_FUNDAMENTAL_MAX* = 255 shl G_TYPE_FUNDAMENTAL_SHIFT

# =============================================================================
# COMPLEX TYPES
# =============================================================================

type
  GtkTreeIter* {.bycopy.} = object
    stamp*: gint
    user_data*: gpointer
    user_data2*: gpointer
    user_data3*: gpointer

  GValue* {.bycopy.} = object
    g_type*: gsize
    data*: array[2, uint64]

# =============================================================================
# GTK INITIALIZATION AND MAIN LOOP
# =============================================================================

proc gtk_init*(argc: ptr cint, argv: ptr ptr cstring) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_main*() {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_main_quit*() {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# WIDGET FUNCTIONS
# =============================================================================

proc gtk_widget_show_all*(widget: GtkWidget) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_widget_destroy*(widget: GtkWidget) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_widget_set_sensitive*(widget: GtkWidget, sensitive: gboolean) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_widget_set_size_request*(widget: GtkWidget, width: gint, height: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_widget_set_halign*(widget: GtkWidget, align: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_widget_set_valign*(widget: GtkWidget, align: gint) {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# WINDOW FUNCTIONS
# =============================================================================

proc gtk_window_new*(window_type: GtkWindowType): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_window_set_title*(window: GtkWidget, title: cstring) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_window_set_default_size*(window: GtkWidget, width: gint, height: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_window_set_resizable*(window: GtkWidget, resizable: gboolean) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_window_set_decorated*(window: GtkWidget, setting: gboolean) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_window_set_position*(window: GtkWidget, position: gint) {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# CONTAINER FUNCTIONS
# =============================================================================

proc gtk_container_add*(container: GtkWidget, widget: GtkWidget) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_container_set_border_width*(container: GtkWidget, border_width: guint) {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# LAYOUT FUNCTIONS
# =============================================================================

# Box layout
proc gtk_box_new*(orientation: GtkOrientation, spacing: gint): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_box_pack_start*(box: GtkWidget, child: GtkWidget, expand: gboolean, fill: gboolean, padding: guint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_box_pack_end*(box: GtkWidget, child: GtkWidget, expand: gboolean, fill: gboolean, padding: guint) {.cdecl, importc, dynlib: GTK_LIB.}

# Fixed container
proc gtk_fixed_new*(): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_fixed_put*(fixed: GtkWidget, widget: GtkWidget, x: gint, y: gint) {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# BUTTON FUNCTIONS
# =============================================================================

proc gtk_button_new_with_label*(label: cstring): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_check_button_new_with_label*(label: cstring): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_toggle_button_get_active*(togglebutton: GtkWidget): gboolean {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# LABEL FUNCTIONS
# =============================================================================

proc gtk_label_new*(str: cstring): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_text*(label: GtkWidget, str: cstring) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_line_wrap*(label: GtkWidget, wrap: gboolean) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_line_wrap_mode*(label: GtkWidget, wrap_mode: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_max_width_chars*(label: GtkWidget, n_chars: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_width_chars*(label: GtkWidget, n_chars: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_justify*(label: GtkWidget, jtype: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_label_set_ellipsize*(label: GtkWidget, mode: gint) {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# PROGRESS BAR FUNCTIONS
# =============================================================================

proc gtk_progress_bar_new*(): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_progress_bar_set_fraction*(pbar: GtkWidget, fraction: gdouble) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_progress_bar_set_text*(pbar: GtkWidget, text: cstring) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_progress_bar_set_show_text*(pbar: GtkWidget, show_text: gboolean) {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# ENTRY FUNCTIONS
# =============================================================================

proc gtk_entry_new*(): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_entry_get_text*(entry: GtkWidget): cstring {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_entry_set_text*(entry: GtkWidget, text: cstring) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_entry_set_completion*(entry: GtkWidget, completion: GtkWidget) {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# ENTRY COMPLETION FUNCTIONS
# =============================================================================

proc gtk_entry_completion_new*(): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_entry_completion_set_model*(completion: GtkWidget, model: GtkListStore) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_entry_completion_set_text_column*(completion: GtkWidget, column: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_entry_completion_set_popup_completion*(completion: GtkWidget, popup_completion: gboolean) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_entry_completion_set_minimum_key_length*(completion: GtkWidget, length: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_entry_completion_set_popup_single_match*(completion: GtkWidget, popup_single_match: gboolean) {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# COMBOBOX FUNCTIONS
# =============================================================================

proc gtk_combo_box_text_new_with_entry*(): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_combo_box_text_append_text*(combo_box: GtkWidget, text: cstring) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_combo_box_get_model*(combo_box: GtkWidget): pointer {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_bin_get_child*(bin: GtkWidget): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# LIST STORE FUNCTIONS
# =============================================================================

proc gtk_list_store_new*(n_columns: gint, first_type: gint): GtkListStore {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_list_store_clear*(store: GtkListStore) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_list_store_append*(store: GtkListStore, iter: ptr GtkTreeIter) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_list_store_set*(store: GtkListStore, iter: pointer, column: gint, value: cstring, terminator: gint) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_list_store_set_value*(store: GtkListStore, iter: ptr GtkTreeIter, column: gint, value: ptr GValue) {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# MENU FUNCTIONS
# =============================================================================

proc gtk_menu_new*(): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_menu_item_new_with_label*(label: cstring): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_menu_item_get_label*(menu_item: GtkWidget): cstring {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_menu_shell_append*(menu_shell: GtkWidget, child: GtkWidget) {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_menu_popup_at_widget*(menu: GtkWidget, widget: GtkWidget, 
                              widget_anchor: GdkGravity,
                              menu_anchor: GdkGravity,
                              trigger_event: GdkEvent) {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# DIALOG FUNCTIONS
# =============================================================================

proc gtk_dialog_run*(dialog: GtkWidget): gint {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_file_chooser_dialog_new*(title: cstring, parent: GtkWidget, action: GtkFileChooserAction,
                                first_button_text: cstring, first_response_id: gint,
                                second_button_text: cstring, second_response_id: gint,
                                terminator: cstring = nil): GtkWidget {.cdecl, importc, dynlib: GTK_LIB.}
proc gtk_file_chooser_get_filename*(chooser: GtkWidget): cstring {.cdecl, importc, dynlib: GTK_LIB.}

# =============================================================================
# SIGNAL FUNCTIONS
# =============================================================================

proc g_signal_connect_data*(instance: gpointer, detailed_signal: cstring, 
                           c_handler: pointer, data: gpointer, 
                           destroy_data: pointer, connect_flags: guint): culong {.
  cdecl, importc, dynlib: GLIB_LIB.}

# =============================================================================
# GOBJECT FUNCTIONS
# =============================================================================

proc g_value_init*(value: ptr GValue, g_type: gsize) {.cdecl, importc, dynlib: GLIB_LIB.}
proc g_value_set_string*(value: ptr GValue, v_string: cstring) {.cdecl, importc, dynlib: GLIB_LIB.}
proc g_value_unset*(value: ptr GValue) {.cdecl, importc, dynlib: GLIB_LIB.}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

proc G_TYPE_FUNDAMENTAL*(gtype: gsize): gsize =
  result = gtype and G_TYPE_FUNDAMENTAL_MAX

proc G_VALUE_TYPE*(value: ptr GValue): gsize =
  result = value.g_type

proc G_VALUE_HOLDS_STRING*(value: ptr GValue): bool =
  result = G_TYPE_FUNDAMENTAL(G_VALUE_TYPE(value)) == G_TYPE_STRING

proc init_string_value*(value: var GValue) =
  g_value_init(addr value, G_TYPE_STRING)

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