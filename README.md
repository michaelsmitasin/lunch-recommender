To use this, you'll need to create a free account on Yelp and OpenWeatherMap, and request API keys, then edit this script to include those keys.

You'll also need a few fairly standard Linux/Unix tools installed like curl/jot/jq.

This was written on FreeBSD so the "date" command uses the -j flag, which is unnecessary for Linux, so if you plan to run on Linux you'll want to modify that date command.

Finally, you'll need to enter the latitude/longitude in decimal format (not deg/min/sec) to center the search radius.

You can run this interactively or provide it the -e option with an email address to have it run on a schedule.

Example email:
`
To: recipient@example.com
Subject: Lunch selection for Wed, 2019-11-06
Current weather: haze
Current temperature: 58 F
Weather adapted search radius: .50 miles

Selection:
Sandwich Zone
4 stars
153 reviews
Sandwiches
Delis
2117 Shattuck Ave
Berkeley, CA 94704

Generated from /usr/local/bin/LUNCH.sh`
