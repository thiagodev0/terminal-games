CXX = g++
CC = gcc

CXXFLAGS = -std=c++17 -I./src -I./src/lua -Wall -Wextra -O2
CFLAGS = -I./src/lua -Wall -Wextra -O2

SRC_CPP = src/main.cpp
LUA_C_SRC = $(wildcard src/lua/*.c)

OBJ_CPP = $(SRC_CPP:.cpp=.o)
OBJ_LUA = $(LUA_C_SRC:.c=.o)
OBJ = $(OBJ_CPP) $(OBJ_LUA)

OUT = terminal-games

all: $(OUT)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OUT): $(OBJ)
	$(CXX) $(OBJ) -o $@

clean:
	-$(RM) $(OBJ) $(OUT)

.PHONY: all clean