# Generating Bazel Build Files for wayland (AEMU)

This document explains how to generate Bazel build files for the `wayland` project, specifically for use within the Android Emulator (AEMU) development environment.

## Tl;dr:
### To generate the bazel files:
```bash
./aemu-bazel/generate_bazel_files.sh
unzip aemu-bazel/amc-build/bazel*.zip
mv platform/BUILD.linux-x86_64 BUILD.bazel
```

### To test the bazel build:
```bash
bazel build ...
```

## Purpose

The `aemu-bazel/generate_bazel_files.sh` script automates the creation of Bazel `BUILD` files for `wayland` using the `amc.py` toolchain script. This allows `wayland` to be built and integrated into a Bazel-based AEMU project.

## Prerequisites

*   An Android Open Source Project (AOSP) checkout.
*   The `amc.py` toolchain script available at `$AOSP_ROOT/hardware/google/aemu/tools/toolchain/src/amc.py`.

## How to Generate Bazel Files

1.  **Navigate to the `wayland` repository root:**
    The `generate_bazel_files.sh` script is designed to be run from the top-level `wayland` directory.

    ```bash
    cd /path/to/your/aosp/third_party/wayland
    ```

2.  **Run the generation script:**
    Execute the script from the `wayland` root. The script will automatically deduce the `AOSP_ROOT` based on its own location (assuming it's in `$AOSP_ROOT/third_party/wayland/aemu-bazel`).

    ```bash
    ./aemu-bazel/generate_bazel_files.sh
    ```

## What the Script Does

*   **Deduces `AOSP_ROOT`**: It determines the root of your AOSP checkout.
*   **Changes Directory**: It changes the current working directory to the `wayland` repository root (`third_party/wayland`).
*   **Executes `amc.py`**: It calls the `amc.py` script with the necessary configuration files (`aemu-bazel/aemu-wayland-build-config.jsonc` and `aemu-bazel/aemu-wayland-shim.jsonc`) to generate the Bazel build files.

## Output

The generated Bazel build files will be placed in the `amc-build` directory within the `wayland` repository root (e.g., `/path/to/your/aosp/third_party/wayland/amc-build`).
