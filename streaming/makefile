# === CONFIGURATION ===
CXX := g++
CXXFLAGS := -std=c++17 -Wall

SRC := serial_stream.cpp
TARGET := serial_stream

# Platform-specific flags
ifeq ($(OS),Windows_NT)
    EXEC := $(TARGET).exe
    CXXFLAGS += -D_CRT_SECURE_NO_WARNINGS
else
    EXEC := $(TARGET)
    SRC := posix_serial_stream.cpp
endif

# === BUILD RULES ===

all: $(EXEC)

$(EXEC): $(SRC)
	$(CXX) $(CXXFLAGS) -o $@ $^

clean:
	rm -f $(EXEC)