# Reading Apple Bits

## Disable SEP and AMFI

Reboot into 1TR

`bputil -r`

`csrutil disable`

`nvram boot-args="boot-args	nvme=0xff -v iotrace keepsyms kmem -enable_kprintf_spam kdebug_trace -arm64e_preview_abi debug=0x44 wdt=-1 ean-debug=0xFF amfi_get_out_of_my_way=1 trace trm_enabled"`

## Reading the EAN

EAN is some NOR like structure.  To be able to read it, you must boot with SIP off and AMFI off (as this requires the
entitlements file provided).  One can also add `ean-debug` to the boot args to both get a listing of images (i used mine
as a basis) as well as debug any issues.  If the program runs, you will get a bunch of `ean.0xXXXXXXXX.bin` files,
being read out of EAN

No warranty - as usual
