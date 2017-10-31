#!/usr/bin/env sh
set -e

# No args or looks like options or the APP_MODULE for Gunicorn
if [ "$#" = 0 ] || \
    [ "${1#-}" != "$1" ] || \
    echo "$1" | grep -Eq '^([_A-Za-z]\w*\.)*[_A-Za-z]\w*:[_A-Za-z]\w*$'; then
  set -- gunicorn "$@"
fi

if [ "$1" = 'gunicorn' ]; then
  # Do an extra chown of the /app directory at runtime in addition to the one in
  # the build process in case any directories are mounted as root-owned volumes
  # at runtime.
  chown -R apistar:apistar /app

  nginx -g 'daemon off;' &

  # Set some sensible Gunicorn options, needed for things to work with Nginx

  # umask working files (worker tmp files & unix socket) as 0o117 (i.e. chmod as
  # 0o660) so that they are only read/writable by apistar and nginx users.
  set -- su-exec apistar "$@" \
    --pid /var/run/gunicorn/gunicorn.pid \
    --bind unix:/var/run/gunicorn/gunicorn.sock \
    --umask 0117 \
    ${GUNICORN_ACCESS_LOGS:+--access-logfile -}
fi

exec "$@"
