#!/bin/sh
set -e

cat <<'EOF' > /etc/profile.d/shared.sh
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

[ -d /shared/appl/bin ] && pathmunge /shared/appl/bin after
[ -d /data/appl/bin ] && pathmunge /data/appl/bin after
unset -f pathmunge

for i in /{shared,data}/appl/profile.d/*.sh ; do
	if [ -r "$i" ]; then
		if [ "$PS1" ]; then
			. "$i"
		else
			. "$i" >/dev/null
		fi
	fi
done
EOF

cat <<'EOF' > /etc/profile.d/shared.csh
foreach p ( /shared/appl/bin /data/appl/bin )
	switch (":${PATH}:")
	case "*:${p}:*":
		breaksw
	default:
		if ( $uid == 0 ) then
			set path = ( ${p} ${path:q} )
		else
			set path = ( ${path:q} ${p} )
		endif
		breaksw
	endsw
end
unset p

set nonomatch
foreach i ( /shared/appl/profile.d/*.csh /data/appl/profile.d/*.csh )
	if ( -r "$i" ) then
		if ($?prompt) then
			source "$i"
		else
			source "$i" >&/dev/null
		endif
	endif
end
unset i nonomatch
EOF
