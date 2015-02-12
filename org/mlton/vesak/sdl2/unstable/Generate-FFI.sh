#!/bin/bash

# Copyright (C) 2007 Vesa Karvonen
#
# This code is released under the MLton license, a BSD-style license.
# See the LICENSE file or http://mlton.org/License for details.

set -e
set -x

##########################################################################
# Configuration

prefix=/usr/include
GL=$prefix/GL
SDL=$prefix/SDL2
linkage=shared

#SDL_endian.h is giving problems with constant definition

headers="
$SDL/SDL_keycode.h
$SDL/SDL_atomic.h
$SDL/SDL_audio.h
$SDL/SDL_bits.h
$SDL/SDL_blendmode.h
$SDL/SDL_clipboard.h
$SDL/SDL_cpuinfo.h
$SDL/SDL_error.h
$SDL/SDL_events.h
$SDL/SDL_filesystem.h
$SDL/SDL_gamecontroller.h
$SDL/SDL_gesture.h
$SDL/SDL.h
$SDL/SDL_haptic.h
$SDL/SDL_hints.h
$SDL/SDL_joystick.h
$SDL/SDL_keyboard.h
$SDL/SDL_log.h
$SDL/SDL_messagebox.h
$SDL/SDL_mouse.h
$SDL/SDL_mutex.h
$SDL/SDL_name.h
$GL/gl.h
$SDL/SDL_opengl.h
$SDL/SDL_pixels.h
$SDL/SDL_platform.h
$SDL/SDL_power.h
$SDL/SDL_quit.h
$SDL/SDL_rect.h
$SDL/SDL_render.h
$SDL/SDL_revision.h
$SDL/SDL_rwops.h
$SDL/SDL_scancode.h
$SDL/SDL_shape.h
$SDL/SDL_surface.h
$SDL/SDL_system.h
$SDL/SDL_syswm.h
$SDL/SDL_thread.h
$SDL/SDL_timer.h
$SDL/SDL_touch.h
$SDL/SDL_types.h
$SDL/SDL_version.h
$SDL/SDL_video.h
"

##########################################################################
# MLton Platform

arch="$(mlton -show path-map | awk '/^TARGET_ARCH/ {print $2}')"
os="$(mlton -show path-map | awk '/^TARGET_OS/ {print $2}')"
target="$arch-$os"
outdir=generated/$target

mkdir -p $outdir

##########################################################################
# Generate FFI for MLton

rm -rf $outdir/mlton
mkdir -p $outdir/mlton
mlnlffigen -linkage $linkage \
           -dir $outdir/mlton -collect true                     \
           -cppopt "-I$SDL -include detail/config/$target.h"    \
           $headers

gcc -o "/tmp/constants.exe" detail/constants.c
cd "${outdir}"
/tmp/constants.exe > constants.sml
