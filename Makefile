BINDIR ?= bin
OBJDIR ?= obj

.PHONY: build
build: build-prep $(BINDIR)/image-bios.bin $(BINDIR)/image-optrom.bin

.PHONY: build-prep
build-prep:
	mkdir -p $(BINDIR) $(OBJDIR)

$(BINDIR)/%.bin $(BINDIR)/%.lst: %.asm $(wildcard *.inc) $(OBJDIR)/checksum
	nasm -f bin $< -o $@ -l $(@:.bin=.lst)
	$(OBJDIR)/checksum $@
	hexdump -C $@ ; true

$(OBJDIR)/checksum: $(OBJDIR)/checksum.o
	$(CC) $^ -o $@

$(OBJDIR)/checksum.o: checksum.c
	$(CC) -c $^ -o $@

.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
