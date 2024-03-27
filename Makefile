BINDIR ?= bin
OBJDIR ?= obj

.PHONY: build
build: build-prep $(BINDIR)/image.bin

.PHONY: build-prep
build-prep:
	mkdir -p $(BINDIR) $(OBJDIR)

$(BINDIR)/%.bin $(BINDIR)/%.lst: %.asm $(wildcard *.inc)
	nasm -f bin $< -o $@ -l $(@:.bin=.lst)
	hexdump -C $@ ; true

.PHONY: clean
clean:
	rm -rf $(BINDIR) $(OBJDIR)
