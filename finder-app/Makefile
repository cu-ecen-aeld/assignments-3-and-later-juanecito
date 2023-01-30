

# CROSS_COMPILE := aarch64-none-linux-gnu-
CROSS_COMPILE :=
CC := gcc


all: writer

writer: writer.c
		$(CROSS_COMPILE)$(CC) writer.c -o writer

clean:
	rm -f writer