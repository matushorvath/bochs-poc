BINDIR ?= bin
OBJDIR ?= obj

ifeq ($(OS), Windows_NT)
	PLATFORM := windows
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S), Linux)
		PLATFORM := linux
	endif
	ifeq ($(UNAME_S), Darwin)
		PLATFORM := macos
	endif
endif

.PHONY: build
build: prep $(BINDIR)/image.vm8086.bin $(BINDIR)/image.bochs.bin

$(BINDIR)/%.bochs.bin: %.asm $(wildcard *.inc) $(OBJDIR)/checksum
	nasm -d BOCHS -f bin $< -o $@
	$(OBJDIR)/checksum $@ || rm $@
	hexdump -C $@ ; true

$(BINDIR)/%.vm8086.bin: %.asm $(wildcard *.inc)
	nasm -d VM8086 -f bin $< -o $@
	hexdump -C $@ ; true

$(OBJDIR)/checksum: $(OBJDIR)/checksum.o
	$(CC) $^ -o $@

$(OBJDIR)/checksum.o: checksum.c
	$(CC) -c $^ -o $@

.PHONY: run
run: prep $(BINDIR)/image.bochs.out

$(BINDIR)/%.bochs.out: $(BINDIR)/%.bochs.bin
	echo continue | bochs -q -f bochsrc.${PLATFORM} \
		"optromimage1:file=$<,address=0xd0000" "com1:dev=$@" || true

.PHONY: prep
prep:
	mkdir -p $(BINDIR) $(OBJDIR)

.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
