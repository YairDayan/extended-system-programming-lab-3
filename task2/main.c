#include "util.h"

#define SYS_EXIT 1
#define SYS_WRITE 4
#define STDOUT 1
#define SYS_OPEN 5
#define SYS_CLOSE 6
#define SYS_GETDENTS 141
#define O_RDONLY 0
#define BUF_SIZE 8192

extern int system_call();

typedef struct ent {
    int inode;
    int offset;
    short len;
    char buf[1];
} ent;

int main(int argc, char *argv[], char *envp[])
{
    char buf[BUF_SIZE];
    char newline = '\n';
    char *prefix = 0;
    int i;
    int fd;
    int count;
    int pos;
    ent *e;

    for (i = 1; i < argc; i++) {
        if (argv[i][0] == '-' && argv[i][1] == 'a')
            prefix = argv[i] + 2;
    }

    fd = system_call(SYS_OPEN, ".", O_RDONLY, 0);
    if (fd < 0)
        system_call(SYS_EXIT, 0x55, 0, 0);

    count = system_call(SYS_GETDENTS, fd, buf, BUF_SIZE);
    if (count < 0)
        system_call(SYS_EXIT, 0x55, 0, 0);

    pos = 0;
    while (pos < count) {
        e = (ent *)(buf + pos);
        if (prefix == 0 || strncmp(e->buf, prefix, strlen(prefix)) == 0) {
            system_call(SYS_WRITE, STDOUT, e->buf, strlen(e->buf));
            system_call(SYS_WRITE, STDOUT, &newline, 1);
        }
        if (e->len <= 0)
            break;
        pos += e->len;
    }

    system_call(SYS_CLOSE, fd, 0, 0);
    return 0;
}
