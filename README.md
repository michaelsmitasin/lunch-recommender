To use this, you'll need to create accounts on Yelp and OpenWeatherMap, and request API keys, then edit this script to include those keys.

You'll also need a few fairly standard Linux/Unix tools installed like curl/jot/jq.

This was written on FreeBSD so the "date" command uses the -j flag, which is unnecessary for Linux, so if you plan to run on Linux you'll want to modify that date command.

Finally, you'll need to enter the latitude/longitude in decimal format (not deg/min/sec) to center the search radius.
