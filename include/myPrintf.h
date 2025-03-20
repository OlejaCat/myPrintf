#ifndef MY_PRINTF_H
#define MY_PRINTF_H

#ifdef __cplusplus
    extern "C" int myPrintf(const char* format_string, ...)
            __attribute__((format(printf, 1, 2)));
#else
    int myPrintf(const char* format_string, ...)
            __attribute__((format(printf, 1, 2)));
#endif

#endif
