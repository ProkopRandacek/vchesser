SRC = src
OBJ = obj

SOURCES = $(wildcard $(SRC)/*.c)
OBJECTS = $(patsubst $(SRC)/%.c, $(OBJ)/%.o, $(SOURCES))

GCC_WFLAGS  = -Wall -Wextra -Wfloat-equal -Wundef -Wshadow -Wpointer-arith -Wcast-align -Wstrict-prototypes -Wwrite-strings -Wcast-qual -Wswitch-default -Wswitch-enum -Wconversion -Wunreachable-code -Wformat=2 -Winit-self -Wuninitialized -Waggregate-return -Wno-misleading-indentation -Wno-format-nonliteral
GCC_FLAGS   = $(GCC_WFLAGS) -std=c11 -Ofast -march=native #-g
GCC_LIB     = -lm

NAME = chess
BUILD_NAME = $(shell git rev-parse --short HEAD)
BUILD_TIME = $(shell date +'%H%M%S_%d%m%y')
BUILD_DIR  = build

GCC_FULL = $(GCC_FLAGS) $(GCC_LIB) -DBUILD_NAME=\"$(BUILD_NAME)\"

.PHONY: dirs

all: dirs build

dirs:
	mkdir build obj -p

build: $(OBJECTS)
	@echo Building the binary
	gcc $(OBJECTS) $(GCC_FULL) -o $(BUILD_DIR)/$(NAME)
	@echo Build succeeded

$(OBJ)/%.o: $(SRC)/%.c
	gcc $(GCC_FULL) -c $< -o $@

clear:
	rm $(BUILD_DIR) $(OBJ) -rf

clean: clear

run: dirs build
	@echo
	@echo "###############"
	@echo
	@cd $(BUILD_DIR) && ./$(NAME)
