#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_root"

qt_tool() {
    local name=$1 directory
    if command -v "$name" >/dev/null 2>&1; then
        command -v "$name"
        return
    fi
    for directory in "${QT_BIN_DIR:-}" /usr/lib/qt6/bin /usr/lib64/qt6/bin; do
        if [[ -n "$directory" && -x "$directory/$name" ]]; then
            printf '%s\n' "$directory/$name"
            return
        fi
    done
    printf 'Cannot find %s; add Qt tools to PATH or set QT_BIN_DIR.\n' "$name" >&2
    return 1
}

formatter=$(qt_tool qmlformat)
linter=$(qt_tool qmllint)
files=(shell.qml core/*.qml services/*.qml components/*.qml modules/island/*.qml)

case "${1:-}" in
    --format) "$formatter" --inplace "${files[@]}" ;;
    "")
        for file in "${files[@]}"; do
            if ! "$formatter" "$file" | cmp --silent "$file" -; then
                printf 'Formatting differs: %s. Run scripts/check-qml.sh --format.\n' "$file" >&2
                exit 1
            fi
        done
        ;;
    *) printf 'Usage: %s [--format]\n' "$0" >&2; exit 1 ;;
esac

# Use Quickshell's generated qs.* modules, including singleton declarations.
# Never source .qmlls.ini as shell code or commit its machine-specific paths.
build_dir=$(sed -n 's/^buildDir="\(.*\)"$/\1/p' .qmlls.ini 2>/dev/null || true)
if [[ -z "$build_dir" || ! -d "$build_dir/qs" ]]; then
    printf 'First run: touch .qmlls.ini && quickshell --path .\n' >&2
    exit 1
fi
import_path_string=$(sed -n 's/^importPaths="\(.*\)"$/\1/p' .qmlls.ini)
IFS=: read -r -a import_paths <<< "$import_path_string"
lint_args=(-I "$build_dir")
for path in "${import_paths[@]}"; do
    lint_args+=(-I "$path")
done
virtual_files=()
for file in "${files[@]}"; do
    virtual_files+=("$build_dir/qs/$file")
done
"$linter" "${lint_args[@]}" "${virtual_files[@]}"
