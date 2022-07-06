ERL_INCLUDE_PATH = $(shell elixir -e "#{:code.root_dir()}/erts-#{:erlang.system_info(:version)/include")
ERL_CFLAGS ?= -I$(ERL_EI_INCLUDE_DIR)
ERL_LDFLAGS ?= -L$(ERL_EI_LIBDIR)
PREFIX = $(MIX_APP_PATH)/priv

all: $(PREFIX)/max_nif.so

$(PREFIX)/max_nif.so: $(PREFIX) c_src/max_nif.m
	clang -framework Cocoa $(ERL_CFLAGS) $(ERL_LDFLAGS) -dynamiclib -undefined dynamic_lookup -o $(PREFIX)/max_nif.so c_src/max_nif.m

$(PREFIX):
	mkdir -p $(PREFIX)
