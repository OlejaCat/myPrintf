#ifndef MY_PRINTF_H
#define MY_PRINTF_H

#if defined(__cplusplus)
extern "C" {
#endif

int myPrintf(const char* format_string, ...)
             __attribute__((format(printf, 1, 2)));

#if defined(__cplusplus)
}
#endif

#endif
