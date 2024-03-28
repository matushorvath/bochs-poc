sudo apt install bochs bochs-term bochs-sdl2 vgabios bochsbios

https://bochs.sourceforge.io/doc/docbook/user/serial-port.html

rm serial.log ; make && echo continue | bochs -q -f bochsrc.${PLATFORM}
