#!/bin/sh

USE_HOST=""
SELECTED=""

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
        if [ -z "${SELECTED}" ]; then
            SELECTED="${KEY}"
        else
            "Unexpected argument: $KEY"
            exit 1
        fi
        ;;
    esac
done

[ -d "$TARGET_DIR" ] || { echo "No writable target directory detected, use --target"; exit 1; }

echo "Installing into ${TARGET_DIR} ..."

for APP_CONFIG in */ddexec.yml; do
    APP="$(dirname "${APP_CONFIG}")"

    [ -n "${SELECTED}" ] && [ "${SELECTED}" != "${APP}" ] && continue

    printf "%s ... " "$APP"

    {
        echo "#!/bin/sh"
        [ -n "${USE_HOST}" ] && {
            echo "export USE_HOST_X11=1"
            echo "export USE_HOST_DBUS=1"
        }
        echo "exec ddexec \\"
        echo "  $(cd "$APP" && pwd)/ddexec.yml \\"
        echo '  "$@"'
    } > "${TARGET_DIR}/${APP}"

    chmod +x "${TARGET_DIR}/${APP}"

    echo "done"
done
