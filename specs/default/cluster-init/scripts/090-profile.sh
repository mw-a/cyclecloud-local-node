#!/bin/sh
set -e

cat <<'EOF' > /etc/profile.d/data.sh
pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}

pathmunge /data/appl/bin after

unset -f pathmunge

for i in /data/appl/profile.d/*.sh; do
	if [ -r "$i" ]; then
		if [ "$PS1" ]; then
			. "$i"
		else
			. "$i" >/dev/null
		fi
	fi
done
EOF
