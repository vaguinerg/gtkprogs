import posix

proc setlocale(category: cint, locale: cstring): cstring {.importc: "setlocale", header: "<locale.h>".}
proc bindtextdomain(domainname, dirname: cstring): cstring {.importc, header: "<libintl.h>".}
proc textdomain(domainname: cstring): cstring {.importc, header: "<libintl.h>".}
proc gettext(msgid: cstring): cstring {.importc, header: "<libintl.h>".}

template `gettext`*(msg: string): cstring =
  gettext(msg.cstring)

proc initGettext*(domain, localedir: string) =
  discard setlocale(LC_ALL, "".cstring)
  discard bindtextdomain(domain.cstring, localedir.cstring)
  discard textdomain(domain.cstring)
