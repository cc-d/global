#include <stdio.h>
#include <sys/time.h>

int main() {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    unsigned long sec = tv.tv_sec;
    unsigned long usec = tv.tv_usec;
    printf(
        "%ld.%ld\n", sec, usec
    );
}