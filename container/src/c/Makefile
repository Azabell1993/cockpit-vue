# Makefile
CC = gcc
CFLAGS = -I/usr/include/libmount -I/usr/include/blkid -I/usr/include/sysprof-4 -pthread -Wall -Wwrite-strings -ggdb3 -I/usr/include/glib-2.0 -I/usr/lib/x86_64-linux-gnu/glib-2.0/include -I/usr/include/libmount -I/usr/include/blkid -I/usr/include/json-glib-1.0 -I/usr/include/libsoup-2.4 -pthread -I/usr/include/libxml2
LDFLAGS = -lsoup-2.4 -ljson-glib-1.0 -lglib-2.0 -lgobject-2.0 -lgio-2.0

TARGET = cockpit-cloud-connector

all: $(TARGET)

$(TARGET): cockpit-cloud.o
	$(CC) $(CFLAGS) -o $(TARGET) cockpit-cloud.o $(LDFLAGS)

cockpit-cloud.o: cockpit-cloud.c
	$(CC) $(CFLAGS) -c cockpit-cloud.c -o cockpit-cloud.o

clean:
	rm -f *.o $(TARGET)
