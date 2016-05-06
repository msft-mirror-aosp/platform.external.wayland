# Copyright (C) 2015 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

LOCAL_PATH := $(call my-dir)

WAYLAND_CFLAGS := -Wall -Wextra -Wno-unused-parameter -g -Wstrict-prototypes
WAYLAND_CFLAGS += -Wmissing-prototypes -fvisibility=hidden -Wno-pointer-arith

WAYLAND_VERSION_MAJOR := 1
WAYLAND_VERSION_MINOR := 9
WAYLAND_VERSION_MICRO := 91
WAYLAND_VERSION := "1.9.91"

WAYLAND_TEMPLATE_SUBST := -e s/@WAYLAND_VERSION_MAJOR@/$(WAYLAND_VERSION_MAJOR)/
WAYLAND_TEMPLATE_SUBST += -e s/@WAYLAND_VERSION_MINOR@/$(WAYLAND_VERSION_MINOR)/
WAYLAND_TEMPLATE_SUBST += -e s/@WAYLAND_VERSION_MICRO@/$(WAYLAND_VERSION_MICRO)/
WAYLAND_TEMPLATE_SUBST += -e s/@WAYLAND_VERSION@/$(WAYLAND_VERSION)/


###############################################################################
# Build wayland_scanner, used to generate code

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	src/scanner.c \
	src/wayland-util.c \

LOCAL_STATIC_LIBRARIES := \
	libexpat \

LOCAL_C_INCLUDES := \
	external/expat/lib \

LOCAL_CFLAGS += $(WAYLAND_CFLAGS)

LOCAL_MODULE := wayland_scanner
LOCAL_MODULE_TAGS := optional
include $(BUILD_HOST_EXECUTABLE)


###############################################################################
# Build libwayland_client

include $(CLEAR_VARS)

LOCAL_SRC_FILES := \
	src/connection.c \
	src/wayland-client.c \
	src/wayland-os.c \
	src/wayland-util.c \

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH)/src \
	device/google/cheets2/external/cheets-libffi/$(TARGET_OS)-$(TARGET_ARCH) \

LOCAL_STATIC_LIBRARIES := \
	cheets-libffi \

LOCAL_CFLAGS += $(WAYLAND_CFLAGS)

LOCAL_MODULE := libwayland_client
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := STATIC_LIBRARIES
LOCAL_EXPORT_C_INCLUDE_DIRS := $(LOCAL_PATH)/src

# These files are generated, and we must make them a dependency to ensure they
# are generated before we try to include them.
LOCAL_ADDITIONAL_DEPENDENCIES += \
	device/google/cheets2/external/cheets-libffi/include/ffi.h \

# --- Generate the client protocol implementation data
generated_sources := $(call local-generated-sources-dir)
GEN := $(addprefix $(generated_sources)/, \
						wayland-protocol.c \
				)
LOCAL_GENERATED_SOURCES += $(GEN)
$(GEN) : PRIVATE_PATH := $(LOCAL_PATH)
$(GEN) : PRIVATE_CUSTOM_TOOL = $(HOST_OUT_EXECUTABLES)/wayland_scanner code < $< > $@
$(GEN) : $(HOST_OUT_EXECUTABLES)/wayland_scanner
$(GEN) : $(generated_sources)/%-protocol.c : $(LOCAL_PATH)/protocol/%.xml
	$(transform-generated-source)
# Note: The line above must be indented with tabs.

# --- Generate the client protocol headers
# We must put the output where the users of the library can see it.
GEN := $(addprefix $(LOCAL_PATH)/src/, \
						wayland-client-protocol.h \
				)
LOCAL_ADDITIONAL_DEPENDENCIES += $(GEN)
$(GEN) : PRIVATE_PATH := $(LOCAL_PATH)
$(GEN) : PRIVATE_CUSTOM_TOOL = $(HOST_OUT_EXECUTABLES)/wayland_scanner client-header < $< > $@
$(GEN) : $(HOST_OUT_EXECUTABLES)/wayland_scanner
$(GEN) : $(LOCAL_PATH)/src/%-client-protocol.h : $(LOCAL_PATH)/protocol/%.xml
	$(transform-generated-source)
# Note: The line above must be indented with tabs.

# Ensure we generate the headers before they are used by any clients of the
# library.
# TODO(lpique): Introduce and upstream a LOCAL_EXPORT_C_GEN_INCLUDES setting
# which adds this in build/core/binary.mk, to avoid relying on build internals.
$(call local-intermediates-dir)/export_includes : $(GEN)

# --- Generate wayland-version.h from wayland-version.h.in
# We must put the output where the users of the library can see it.
GEN := $(addprefix $(LOCAL_PATH)/src/, \
						wayland-version.h \
				)
LOCAL_ADDITIONAL_DEPENDENCIES += $(GEN)
$(GEN) : PRIVATE_PATH := $(LOCAL_PATH)
$(GEN) : PRIVATE_CUSTOM_TOOL = sed $(WAYLAND_TEMPLATE_SUBST) < $< > $@
$(GEN) : $(LOCAL_PATH)/src/%.h : $(LOCAL_PATH)/src/%.h.in
	$(transform-generated-source)
# Note: The line above must be indented with tabs.

# Ensure we generate the headers before they are used by any clients of the
# library.
# TODO(lpique): Introduce and upstream a LOCAL_EXPORT_C_GEN_INCLUDES setting
# which adds this in build/core/binary.mk, to avoid relying on build internals.
$(call local-intermediates-dir)/export_includes : $(GEN)

include $(BUILD_STATIC_LIBRARY)
