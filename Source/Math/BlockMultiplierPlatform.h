//
// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.md file in the project root for full licence information.
//
#pragma once
#ifdef _MSC_VER
#define ALIGNED_ALLOC(bytes,alignment) _aligned_malloc(bytes,alignment)
#define ALIGNED_FREE(ptr) _aligned_free(ptr)
#define FORCEINLINE __forceinline
#else
#ifdef __GNUC__
#include <stdlib.h>
#ifdef __APPLE__
void* aligned_alloc(size_t alignment, size_t size) {
    void* p;
    if (posix_memalign(&p, alignment, size) != 0) {
        p = NULL;
    }
    return p;
}
#endif
#define ALIGNED_ALLOC(bytes,alignment) aligned_alloc(alignment,bytes)
#define ALIGNED_FREE(ptr) free(ptr)
//#define FORCEINLINE __attribute__((always_inline)) 
#define FORCEINLINE inline 
#endif
#endif

