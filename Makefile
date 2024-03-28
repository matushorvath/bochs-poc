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
build: prep $(BINDIR)/image.bin

$(BINDIR)/%.bin $(BINDIR)/%.lst: %.asm $(wildcard *.inc) $(OBJDIR)/checksum
	nasm -f bin $< -o $@ -l $(@:.bin=.lst)
	$(OBJDIR)/checksum $@
	hexdump -C $@ ; true

$(OBJDIR)/checksum: $(OBJDIR)/checksum.o
	$(CC) $^ -o $@

$(OBJDIR)/checksum.o: checksum.c
	$(CC) -c $^ -o $@

.PHONY: run
run: prep $(BINDIR)/image.val

$(BINDIR)/%.val: $(BINDIR)/%.bin
	echo continue | bochs -q -f bochsrc.${PLATFORM} \
		"optromimage1:file=$<,address=0xd0000" "com1:dev=$@" || true

.PHONY: prep
prep:
	mkdir -p $(BINDIR) $(OBJDIR)

.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
