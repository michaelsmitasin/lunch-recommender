To use this, you'll need to:
* create a free account on Yelp and OpenWeatherMap, and request API keys, then edit this script to include those keys.
* install a few fairly standard Linux/Unix tools like curl/jot/jq.
* modify the date command to not use -j if you're running on Linux instead of Unix.
* enter the latitude/longitude in decimal format (not deg/min/sec) to center the search radius.

You can run this interactively or provide it the -e option with an email address to have it run on a schedule.

Example email:

> To: recipient@example.com  
> Subject: Lunch selection for Wed, 2019-11-06  
> Current weather: haze  
> Current temperature: 58 F  
> Weather adapted search radius: .50 miles  
>  
> Selection:  
> Sandwich Zone  
> 4 stars  
> 153 reviews  
> Sandwiches  
> Delis  
> 2117 Shattuck Ave  
> Berkeley, CA 94704  
>   
> Generated from /usr/local/bin/LUNCH.sh  
