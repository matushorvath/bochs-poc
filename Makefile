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
build: prep $(OBJDIR)/image.vm8086.bin $(OBJDIR)/image.bochs.bin

$(OBJDIR)/%.bochs.bin: %.asm $(wildcard *.inc) $(OBJDIR)/checksum
	nasm -d BOCHS -f bin $< -o $@
	$(OBJDIR)/checksum $@ || rm $@
	hexdump -C $@ ; true

$(OBJDIR)/%.vm8086.bin: %.asm $(wildcard *.inc)
	nasm -d VM8086 -f bin $< -o $@
	hexdump -C $@ ; true

$(OBJDIR)/%: $(OBJDIR)/%.o
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(OBJDIR)/%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $^ -o $@

.PHONY: run
run: prep $(BINDIR)/image.bochs.txt

$(BINDIR)/%.txt: $(OBJDIR)/%.serial $(OBJDIR)/dump_state
	$(OBJDIR)/dump_state $< $@

$(OBJDIR)/%.serial: $(OBJDIR)/%.bin
	echo continue | bochs -q -f bochsrc.${PLATFORM} \
		"optromimage1:file=$<,address=0xd0000" "com1:dev=$@" || true

.PHONY: prep
prep:
	rm -f $(BINDIR)/*.out
	mkdir -p $(BINDIR) $(OBJDIR)

.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)

# Keep all automatically generated files (e.g. object files)
.SECONDARY:
