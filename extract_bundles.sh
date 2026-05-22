#!/usr/bin/env bash

#
# Recursively find and extract all *.bundle files
# into their current directory.
#
# Assumes *.bundle files are Git bundle repositories.
#
# Usage:
#   chmod +x extract_bundles.sh
#   ./extract_bundles.sh /path/to/root
#

set -euo pipefail

ROOT_DIR="${1:-.}"

if ! command -v git >/dev/null 2>&1; then
    echo "[ERROR] git is not installed."
    exit 1
fi

echo "[*] Searching for .bundle files under: ${ROOT_DIR}"
echo

find "${ROOT_DIR}" -type f -name "*.bundle" | while read -r bundle_file; do

    bundle_dir="$(dirname "${bundle_file}")"
    bundle_name="$(basename "${bundle_file}" .bundle)"

    target_dir="${bundle_dir}/${bundle_name}"

    echo "[*] Processing:"
    echo "    Bundle : ${bundle_file}"
    echo "    Target : ${target_dir}"

    # Skip if target already exists
    if [[ -d "${target_dir}" ]]; then
        echo "    [!] Skipping - target directory already exists"
        echo
        continue
    fi

    mkdir -p "${target_dir}"

    # Clone the git bundle into the target directory
    if git clone "${bundle_file}" "${target_dir}"; then
        echo "    [+] Successfully extracted"
    else
        echo "    [ERROR] Failed to extract: ${bundle_file}"
        rm -rf "${target_dir}"
    fi

    echo

done

echo "[*] Done."

