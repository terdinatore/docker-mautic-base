#!/bin/bash
set -e

current="$(curl https://api.github.com/repos/mautic/mautic/releases/latest -s | jq -r .name)"

# TODO - Expose SHA signatures for the packages somewhere
wget -O mautic.zip https://s3.amazonaws.com/mautic/releases/$current.zip
sha1="$(sha1sum mautic.zip | sed -r 's/ .*//')"

for variant in apache fpm; do
	(
		set -x

		sed -ri '
			s/^(ENV MAUTIC_VERSION) .*/\1 '"$current"'/;
			s/^(ENV MAUTIC_SHA1) .*/\1 '"$sha1"'/;
		' "$variant/Dockerfile"

        # To make management easier, we use these files for all variants
		cp common/* "$variant"/
	)
done

rm mautic.zip
