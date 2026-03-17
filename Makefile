CC = gcc
CFLAGS = -Wall -O2
TARGET = matchstick

all: $(TARGET)

$(TARGET): main.c
	$(CC) $(CFLAGS) -o $(TARGET) main.c

clean:
	rm -f $(TARGET)

test: all
	bash test.sh
