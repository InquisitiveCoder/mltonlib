/* Copyright (C) 2007-2008 Vesa Karvonen
 *
 * This code is released under the MLton license, a BSD-style license.
 * See the LICENSE file or http://mlton.org/License for details.
 */

/* The type __builtin_va_list is built into GCC. Since it has has no definition
 * in the source code it causes parsing to fail. MLton's ml-nlffigen doesn't
 * support varargs anyways, so it shouldn't cause any problems to give it an
 * arbitrary definition. */
#define __builtin_va_list void*

/* The inline keyword causes parsing to fail. */
#define inline

/* SDL_assert.h includes headers that cause parsing to fail.
 * Since it only defines macros it's fine to not include it.
 */
#define _SDL_assert_h

/* SDL_cpuinfo.h uses these macros to include the headers for the x86 SIMD
 * extensions, which cause parsing to fail.
 */
#undef __MMX__
#undef __3dNOW__
#undef __SSE__
#undef __SSE2__

/* SDL_pixels.h needs a macro defined in SDL_stdinc.h, but doesn't include it
 * in versions 2.0.0 and 2.0.1.
 */
#include "SDL2/SDL_stdinc.h"
