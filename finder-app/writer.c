#include <syslog.h>
#include <stdio.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

int main(int argc, char** argv)
{
    // Open log user
    openlog(NULL, 0, LOG_USER);

    // Check arguments
    if (argc != 3)
    {  
        fprintf(stderr, "Error arguments -> %s <file_path> <string> \n", argv[0]);
        syslog(LOG_ERR, "Error arguments -> %s <file_path> <string> \n", argv[0]);
        closelog();
        return 1;
    }

    // Open file
    char file_name[FILENAME_MAX];
    char str[1024];
    memset(file_name, 0, FILENAME_MAX * sizeof(char));
    memset(str, 0, 1024 * sizeof(char));
    strncpy(file_name, argv[1], FILENAME_MAX - 1);
    strncpy(str, argv[2], 1024 - 1);
    int permissions = S_IWUSR | S_IRUSR; // Only user (write / read)

    int fd = open(file_name, O_WRONLY | O_CREAT | O_TRUNC, permissions);
    if (fd == -1)
    {
        int err = errno;
        fprintf(stderr, "Error creating file -> %s %d \n", file_name, err);
        syslog(LOG_ERR, "Error creating file -> %s %d \n", file_name, err);
        closelog();
        return 1;
    }

    int total_write = 0;
    do
    {
        int rc_write = write(fd, str + total_write, strnlen(str, 1024) - total_write);
        if (rc_write == -1)
        {
            int err = errno;
            fprintf(stderr, "Error writing file -> %s %d \n", file_name, err);
            syslog(LOG_ERR, "Error writing file -> %s %d \n", file_name, err);
            closelog();
            close(fd);
            return 1;
        }
        else
        {
            total_write += rc_write;
        }
    }
    while (total_write < strnlen(str, 1024));
    
    syslog(LOG_DEBUG, "String %s has been written in the file %s \n", str, file_name);
    close(fd);
    return 0;
}