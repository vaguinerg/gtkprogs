import lib/[gettext, gtk3minimal]
import os, strutils, osproc, streams, sequtils

initGettext("tinycore", "/usr/local/share/locale")

var
  window: GtkWidget
  networkInterfaceInput: GtkWidget
  dhcpYesBtn: GtkWidget
  dhcpNoBtn: GtkWidget
  ipAddressInput: GtkWidget
  netMaskInput: GtkWidget
  broadcastInput: GtkWidget
  gatewayInput: GtkWidget
  nameserv1Input: GtkWidget
  nameserv2Input: GtkWidget
  saveYesBtn: GtkWidget
  saveNoBtn: GtkWidget
  hostname: string = ""

proc executeCommand(cmd: string): string =
  ## Execute command and return output
  try:
    let (output, _) = execCmdEx(cmd)
    return output.strip()
  except:
    return ""

proc readHostname() =
  ## Read hostname from /etc/hostname
  try:
    hostname = readFile("/etc/hostname").strip()
  except:
    hostname = "localhost"

proc loadNameservers() =
  ## Load current nameservers from /etc/resolv.conf
  let output = executeCommand("grep '^nameserver' /etc/resolv.conf | cut -f2 -d' '")
  let servers = output.splitLines().filterIt(it.len > 0)
  
  if servers.len > 0:
    gtk_entry_set_text(nameserv1Input, servers[0].cstring)
  if servers.len > 1:
    gtk_entry_set_text(nameserv2Input, servers[1].cstring)

proc setInputsEnabled(enabled: bool) =
  ## Enable/disable network configuration inputs
  let sensitive = if enabled: TRUE else: FALSE
  gtk_widget_set_sensitive(ipAddressInput, sensitive)
  gtk_widget_set_sensitive(netMaskInput, sensitive)
  gtk_widget_set_sensitive(broadcastInput, sensitive)
  gtk_widget_set_sensitive(gatewayInput, sensitive)
  gtk_widget_set_sensitive(nameserv1Input, sensitive)
  gtk_widget_set_sensitive(nameserv2Input, sensitive)

proc calculateBroadcast() =
  ## Calculate broadcast address from IP and netmask
  let ip = $gtk_entry_get_text(ipAddressInput)
  let netmask = $gtk_entry_get_text(netMaskInput)
  
  if ip.len > 0 and netmask.len > 0:
    let cmd = "ipcalc -b " & ip & " " & netmask & " | cut -f2 -d="
    let broadcast = executeCommand(cmd)
    if broadcast.len > 0:
      gtk_entry_set_text(broadcastInput, broadcast.cstring)
    
    # Also calculate default gateway (.254)
    let parts = ip.split(".")
    if parts.len == 4:
      let gateway = parts[0] & "." & parts[1] & "." & parts[2] & ".254"
      gtk_entry_set_text(gatewayInput, gateway.cstring)

proc applyNetworkConfig() =
  ## Apply network configuration
  let networkInterface = $gtk_entry_get_text(networkInterfaceInput)
  let ipaddress = $gtk_entry_get_text(ipAddressInput)
  let netmask = $gtk_entry_get_text(netMaskInput)
  let broadcast = $gtk_entry_get_text(broadcastInput)
  let gateway = $gtk_entry_get_text(gatewayInput)
  let nameserver1 = $gtk_entry_get_text(nameserv1Input)
  let nameserver2 = $gtk_entry_get_text(nameserv2Input)
  
  if gtk_toggle_button_get_active(dhcpYesBtn).bool:
    # DHCP configuration
    let cmd = "sudo udhcpc -x hostname:" & hostname & " -b -i " & networkInterface & 
              " -p /var/run/udhcpc." & networkInterface & ".pid &"
    discard execCmd(cmd)
  else:
    # Static IP configuration
    discard execCmd("sudo /usr/bin/pkill udhcpc >/dev/null 2>&1")
    
    let ifconfigCmd = "sudo /sbin/ifconfig " & networkInterface & " " & ipaddress & 
                      " netmask " & netmask & " broadcast " & broadcast & " up"
    discard execCmd(ifconfigCmd)
    
    let routeCmd = "sudo /sbin/route add default gw " & gateway
    discard execCmd(routeCmd)
    
    let dns1Cmd = "echo nameserver " & nameserver1 & " | sudo tee /etc/resolv.conf"
    discard execCmd(dns1Cmd)
    
    if nameserver2.len > 0:
      let dns2Cmd = "echo nameserver " & nameserver2 & " | sudo tee -a /etc/resolv.conf"
      discard execCmd(dns2Cmd)
  
  # Save configuration if requested
  if gtk_toggle_button_get_active(saveYesBtn).bool:
    let scriptPath = "/opt/" & networkInterface & ".sh"
    try:
      let script = open(scriptPath, fmWrite)
      defer: script.close()
      
      script.writeLine("#!/bin/sh")
      script.writeLine("pkill udhcpc")
      
      if gtk_toggle_button_get_active(dhcpYesBtn).bool:
        script.writeLine("udhcpc -b -i " & networkInterface & " -x hostname:" & hostname & 
                        " -p /var/run/udhcpc.eth0.pid")
      else:
        script.writeLine("ifconfig " & networkInterface & " " & ipaddress & " netmask " & 
                        netmask & " broadcast " & broadcast & " up")
        script.writeLine("route add default gw " & gateway)
        script.writeLine("echo nameserver " & nameserver1 & " > /etc/resolv.conf")
        if nameserver2.len > 0:
          script.writeLine("echo nameserver " & nameserver2 & " >> /etc/resolv.conf")
      
      # Make script executable and add to bootlocal.sh
      discard execCmd("sudo chmod +x " & scriptPath)
      discard execCmd("sed -i '/" & networkInterface & ".sh/d' /opt/bootlocal.sh")
      discard execCmd("echo '/opt/" & networkInterface & ".sh &' >> /opt/bootlocal.sh")
      discard execCmd("sed -i '/" & networkInterface & ".sh/d' /opt/.filetool.lst")
      discard execCmd("echo opt/" & networkInterface & ".sh >> /opt/.filetool.lst")
    except:
      echo "Error creating configuration script"

# Signal handlers
proc on_dhcp_yes_toggled(widget: GtkWidget, data: gpointer) {.cdecl.} =
  if gtk_toggle_button_get_active(widget).bool:
    setInputsEnabled(false)

proc on_dhcp_no_toggled(widget: GtkWidget, data: gpointer) {.cdecl.} =
  if gtk_toggle_button_get_active(widget).bool:
    setInputsEnabled(true)

proc on_ip_changed(widget: GtkWidget, data: gpointer) {.cdecl.} =
  calculateBroadcast()

proc on_apply_clicked(widget: GtkWidget, data: gpointer) {.cdecl.} =
  applyNetworkConfig()

proc on_exit_clicked(widget: GtkWidget, data: gpointer) {.cdecl.} =
  gtk3minimal.quit()

proc on_window_destroy(widget: GtkWidget, data: gpointer) {.cdecl.} =
  gtk3minimal.quit()

# Create radio button group helper
proc createRadioGroup(parent: GtkWidget, label: string, option1, option2: string): (GtkWidget, GtkWidget) =
  let group = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10)
  let groupLabel = gtk_label_new(label.cstring)
  gtk_label_set_justify(groupLabel, GTK_JUSTIFY_LEFT)
  
  let vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 5)
  vbox.gtk_box_pack_start(groupLabel, FALSE, FALSE, 0)
  vbox.gtk_box_pack_start(group, FALSE, FALSE, 0)
  parent.gtk_box_pack_start(vbox, FALSE, FALSE, 5)
  
  let btn1 = gtk_check_button_new_with_label(option1.cstring)
  let btn2 = gtk_check_button_new_with_label(option2.cstring)
  
  group.gtk_box_pack_start(btn1, FALSE, FALSE, 0)
  group.gtk_box_pack_start(btn2, FALSE, FALSE, 0)
  
  return (btn1, btn2)

# Create labeled input helper
proc createLabeledInput(parent: GtkWidget, labelText: string, defaultValue: string = ""): GtkWidget =
  let vbox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 2)
  let label = gtk_label_new(labelText.cstring)
  gtk_label_set_justify(label, GTK_JUSTIFY_LEFT)
  gtk_widget_set_halign(label, GTK_ALIGN_START)
  
  let input = gtk_entry_new()
  if defaultValue.len > 0:
    gtk_entry_set_text(input, defaultValue.cstring)
  
  vbox.gtk_box_pack_start(label, FALSE, FALSE, 0)
  vbox.gtk_box_pack_start(input, FALSE, FALSE, 0)
  parent.gtk_box_pack_start(vbox, FALSE, FALSE, 5)
  
  return input

# Initialize GTK
gtk_init()

# Read system information
readHostname()

# Create main window
window = gtk_window_new(GTK_WINDOW_TOPLEVEL)
window.gtk_window_set_title(gettext("Network"))
window.gtk_window_set_default_size(200, 500)
window.gtk_window_set_resizable(FALSE)
window.gtk_container_set_border_width(15)

# Main container
let mainBox = gtk_box_new(GTK_ORIENTATION_VERTICAL, 8)
window.gtk_container_add(mainBox)

# Interface input
networkInterfaceInput = createLabeledInput(mainBox, $gettext("Interface"), "eth0")

# DHCP radio buttons
let (dhcp_yes, dhcp_no) = createRadioGroup(mainBox, $gettext("Use DHCP Broadcast?"), 
                                          $gettext("yes"), $gettext("no"))
dhcpYesBtn = dhcp_yes
dhcpNoBtn = dhcp_no

# Set dhcpNo as default (like original)
gtk_toggle_button_set_active(dhcpNoBtn, TRUE)

# Network configuration inputs
ipAddressInput = createLabeledInput(mainBox, $gettext("IP Address"))
netMaskInput = createLabeledInput(mainBox, $gettext("Network Mask"), "255.255.255.0")
broadcastInput = createLabeledInput(mainBox, $gettext("Broadcast"))
gatewayInput = createLabeledInput(mainBox, $gettext("Gateway"))
nameserv1Input = createLabeledInput(mainBox, $gettext("NameServers"))
nameserv2Input = createLabeledInput(mainBox, "")

# Save configuration radio buttons
let (save_yes, save_no) = createRadioGroup(mainBox, $gettext("Save Configuration?"), 
                                          $gettext("yes"), $gettext("no"))
saveYesBtn = save_yes
saveNoBtn = save_no

# Set saveYes as default (like original)
gtk_toggle_button_set_active(saveYesBtn, TRUE)

# Button box
let buttonBox = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 10)
buttonBox.gtk_widget_set_halign(GTK_ALIGN_CENTER)
mainBox.gtk_box_pack_end(buttonBox, FALSE, FALSE, 10)

# Create buttons
let applyBtn = gtk_button_new_with_label($gettext("Apply"))
let exitBtn = gtk_button_new_with_label($gettext("Exit"))

for btn in [applyBtn, exitBtn]:
  btn.gtk_widget_set_size_request(80, 30)
  buttonBox.gtk_box_pack_start(btn, FALSE, FALSE, 5)

# Connect signals
window.connect("destroy", on_window_destroy)
dhcpYesBtn.connect("toggled", on_dhcp_yes_toggled)
dhcpNoBtn.connect("toggled", on_dhcp_no_toggled)
ipAddressInput.connect("changed", on_ip_changed)
applyBtn.connect("clicked", on_apply_clicked)
exitBtn.connect("clicked", on_exit_clicked)

# Load current nameservers
loadNameservers()

# Show window
window.show()
run()