#!/bin/sh

USE_HOST=""

if [ -d "${HOME}/bin" ]; then
    TARGET_DIR="${HOME}/bin"
elif [ -w "/usr/local/bin/__example" ]; then
    TARGET_DIR="/usr/local/bin"
else
    TARGET_DIR=""
fi

while [ -n "$1" ]; do
    KEY="$1"
    shift

    case "$KEY" in
    --target)
        TARGET_DIR="$1"
        shift
        ;;
    --host)
        USE_HOST=1
        ;;
    -h|--help)
        echo "$0 --target <dir> [--host]"
        exit 0
        ;;
    *)
        "Unexpected argument: $KEY"
        exit 1
        ;;
    esac
done

[ -d "$TARGET_DIR" ] || { echo "No writable target directory detected, use --target"; exit 1; }

echo "Installing into ${TARGET_DIR} ..."

for APP_CONFIG in */ddexec.yml; do
    APP="$(dirname "${APP_CONFIG}")"

    printf "%s ... " "$APP"

    {
        echo "#!/bin/sh"
        echo "exec ddexec \\"
        [ -n "${USE_HOST}" ] && echo "  --host \\"
        echo "  $(cd "$APP" && pwd)/ddexec.yml \\"
        echo '  "$@"'
    } > "${TARGET_DIR}/${APP}"

    chmod +x "${TARGET_DIR}/${APP}"

    echo "done"
done
