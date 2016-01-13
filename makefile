# Template for makefile, with all the dependency generation and obscure flags already set up

SHELL := /bin/bash
MAKEFLAGS := -j
CC := gcc
CXX := g++
DC := gdc

## Project-specific ##
OBJ := foo.o bar.o
BIN := foo
LINKER := $(CXX)
OPTIMIZE_TYPE := NORMAL
###

#NOTE: -g and -flto don't play well together
OPTIMIZE_NONE := -O0 -g
OPTIMIZE_NORMAL := -O3 -DNDEBUG -flto -fwhole-program -fno-math-errno -march=native
OPTIMIZE_UNSAFE := $(OPTIMIZE_NORMAL) -ffast-math -march=native

ALLFLAGS := $(OPTIMIZE_$(OPTIMIZE_TYPE)) -Wall -Wno-unused-result
LDFLAGS := $(OPTIMIZE_$(OPTIMIZE_TYPE)) -lm

CFLAGS := $(ALLFLAGS) -std=c99
CXXFLAGS := $(ALLFLAGS) -std=gnu++11
DFLAGS := $(ALLFLAGS)

.DELETE_ON_ERROR:
.PHONY: all clean asm

all: $(BIN)

$(BIN): $(addprefix obj/,$(OBJ))
	$(LINKER) $^ $(LDFLAGS) -o$@
	ctags *.h *.c *.cpp

clean:
	-rm -- dep/*.dep $(BIN) $(addprefix obj/,$(OBJ))

asm: $(addprefix asm/,$(OBJ:.o=.s))

# Generate annotated assembly.  objdump's annotations are much better than gcc's
asm/%.s: obj/%.o
	@mkdir -p asm
	objdump -S $< > $@

# Object files
obj/%.o: %.c
	@mkdir -p $(dir $@)
	$(CC) -o $@ $(CFLAGS) -c $<

obj/%.o: %.cpp dep/%.dep makefile
	@mkdir -p $(dir $@)
	$(CXX) -o $@ $(CXXFLAGS) -c $<

obj/%.o: %.d dep/%.dep makefile
	@mkdir -p $(dir $@)
	$(DC) -o $@ $(DFLAGS) -c $<

# Dependency Lists
dep/%.dep: %.c makefile
	@mkdir -p $(dir $@);
	@echo -n "$@ " > "$@"
	$(CC) $(CFLAGS) -MM $< >> $@

dep/%.dep: %.cpp makefile
	@mkdir -p $(dir $@);
	@echo -n "$@ " > "$@"
	$(CXX) $(CXXFLAGS) -MM $< >> $@

dep/%.dep: %.d makefile
	@mkdir -p $(dir $@);
	@echo -n "$@ " > "$@"
	$(DC) $(DFLAGS) -MM $< >> $@

ifneq ($(MAKECMDGOALS),clean)
-include $(addprefix dep/, $(OBJ:.o=.dep))
endif

