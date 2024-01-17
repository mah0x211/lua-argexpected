SRCS=$(wildcard src/*.c)
CLIBS=$(SRCS:.c=.$(LIB_EXTENSION))
GCDAS=$(SRCS:.c=.gcda)
INSTALL?=install

ifdef ARGEXPECTED_COVERAGE
COVFLAGS=--coverage
endif

.PHONY: all install

all: $(CLIBS)

%.o: %.c
	$(CC) $(CFLAGS) $(WARNINGS) $(COVFLAGS) $(CPPFLAGS) -o $@ -c $<

%.$(LIB_EXTENSION): %.o
	$(CC) -o $@ $^ $(LDFLAGS) $(LIBS) $(PLATFORM_LDFLAGS) $(COVFLAGS)

install:
	$(INSTALL) argexpected.lua $(INST_LUADIR)
	$(INSTALL) -d $(INST_CLIBDIR)
	$(INSTALL) $(CLIBS) $(INST_CLIBDIR)
	rm -f $(CLIBS) $(GCDAS)
