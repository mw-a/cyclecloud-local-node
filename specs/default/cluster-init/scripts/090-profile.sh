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

cat <<'EOF' > /etc/profile.d/data.csh
foreach p ( /data/appl/bin )
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

if ( -d /etc/profile.d ) then
	set nonomatch
	foreach i ( /data/appl/profile.d/*.csh )
		if ( -r "$i" ) then
			if ($?prompt) then
				source "$i"
			else
				source "$i" >&/dev/null
			endif
		endif
	end
	unset i nonomatch
endif
EOF
