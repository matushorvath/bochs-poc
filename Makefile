ICVM_TYPE ?= c

ICDIR ?= $(abspath ../xzintbit)
VMDIR ?= $(abspath ../vm8086)

ICVM ?= $(abspath $(ICDIR)/vms)/$(ICVM_TYPE)/ic
ICAS ?= $(abspath $(ICDIR)/bin/as.input)
ICBIN2OBJ ?= $(abspath $(ICDIR)/bin/bin2obj.input)
ICLD ?= $(abspath $(ICDIR)/bin/ld.input)
ICLDMAP ?= $(abspath $(ICDIR)/bin/ldmap.input)
LIBXIB ?= $(abspath $(ICDIR)/bin/libxib.a)

LIB8086 ?= $(abspath $(VMDIR)/bin/lib8086.a)
TEST_HEADER ?= $(abspath $(VMDIR)/obj/test_header.o)

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

RESDIR ?= res
OBJDIR ?= obj

.PHONY: test
test: test-prep $(RESDIR)/image.vm8086.txt $(RESDIR)/image.bochs.txt

.PHONY: build
build: test-prep $(OBJDIR)/image.vm8086.bin $(OBJDIR)/image.bochs.bin

.PHONY: test-prep
test-prep:
	rm -f $(RESDIR)/*.txt
	mkdir -p $(RESDIR) $(OBJDIR)

# Run vm8086 binary
$(RESDIR)/%.vm8086.txt: $(OBJDIR)/%.input
	$(ICVM) $< > $@ 2>&1 || ( cat $@ ; false )

$(OBJDIR)/%.input: $(LIB8086) $(LIBXIB) $(TEST_HEADER) $(OBJDIR)/%.o
	echo .$$ | cat $^ - | $(ICVM) $(ICLD) > $@
	echo .$$ | cat $^ - | $(ICVM) $(ICLDMAP) > $@.map.yaml

$(OBJDIR)/%.o: $(OBJDIR)/%.vm8086.bin
	wc -c $< | sed 's/$$/\/binary/' | cat - $< | $(ICVM) $(ICBIN2OBJ) > $@

# Run bochs binary
$(RESDIR)/%.bochs.txt: $(OBJDIR)/%.bochs.serial $(OBJDIR)/dump_state
	$(OBJDIR)/dump_state $< $@

$(OBJDIR)/%.bochs.serial: $(OBJDIR)/%.bochs.bin
	echo continue | bochs -q -f bochsrc.${PLATFORM} \
		"optromimage1:file=$<,address=0xd0000" "com1:dev=$@" || true

# Build the binaries
$(OBJDIR)/%.bochs.bin: %.asm $(wildcard *.inc) $(OBJDIR)/checksum
	nasm -d BOCHS -f bin $< -o $@
	$(OBJDIR)/checksum $@ || rm $@
	hexdump -C $@ ; true

$(OBJDIR)/%.vm8086.bin: %.asm $(wildcard *.inc)
	nasm -d VM8086 -f bin $< -o $@
	hexdump -C $@ ; true

# Build supporting tools
$(OBJDIR)/%: $(OBJDIR)/%.o
	$(CC) $(LDFLAGS) $^ $(LDLIBS) -o $@

$(OBJDIR)/%.o: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $^ -o $@

# Clean
.PHONY: clean
clean:
	rm -rf $(RESDIR) $(OBJDIR)

# Keep all automatically generated files (e.g. object files)
.SECONDARY:
