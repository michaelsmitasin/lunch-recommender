#! /usr/local/bin/bash
###############################################################################
# A script to pick lunch locations for us.
# First fetches weather conditions and sets a walking radius based on those.
# Then fetches restaurants on Yelp with a certain rating within said radius.
# Then selects a random restaurant from that list.
#
# MNSmitasin@lbl.gov 2019-10-04
#
###############################################################################
### LOCAL VARIABLES

# Email Stuff
MAILTO="recipient@example.com"
THISSUBJECT="Lunch selection for $(date -j +"%a, %Y-%m-%d")"

# API Keys
# Define your API keys for these services, or don't be lazy like me and put them in files
YELPAPIKEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
OPENWEATHERAPIKEY="XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"

# Location stuff, set your latitude and longtitude here, which will be the center of the search radius
LAT="XXXXXXXXXXXXXXXXXX"
LONG="XXXXXXXXXXXXXXXXXX"

# Base radius is .5 miles converted to meters
BASERAD="805"

# Number of results to return
LIMIT="1"

###############################################################################
### FUNCTIONS

USAGE(){
        echo "$0"
        echo "Usage:"
        echo "  -e <recipient1,recipient2>              email a comma separated list of recipients"
        echo "  -h                      This help"
        exit 1
}

# Open Weather Stuff
# Modifies the search radius based on current weather conditions, including temperature, rain/sun/snow, etc.
FETCHWEATHER(){
        CURRWEATHER=$(/usr/local/bin/curl -s -X GET "http://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LONG&APPID=$OPENWEATHERAPIKEY")
        CURRWEATHERID=$(echo $CURRWEATHER | /usr/local/bin/jq -cr '.weather[] | .id')
        CURRWEATHERDESC=$(echo $CURRWEATHER | /usr/local/bin/jq -cr '.weather[] | .description')
        CURRWEATHERTEMP=$(echo $CURRWEATHER | /usr/local/bin/jq -cr .main.temp)
        CURRWEATHERTEMPF=$(/usr/bin/bc -l -e "scale = 2; ($CURRWEATHERTEMP - 273.15) * ( 9 / 5 ) + 32" -e quit | cut -d"." -f1)
        case $CURRWEATHERID in
                2*) WEATHERCONDMULTI=".15";; # thunderstorm
                30*) WEATHERCONDMULTI=".5";; # drizzle
                31*) WEATHERCONDMULTI=".25";; # drizzle rain
                5*) WEATHERCONDMULTI=".25";; # rain
                6*) WEATHERCONDMULTI=".25";; # snow
                7*) WEATHERCONDMULTI="1";; # generic atmospheric conditions
                8*) WEATHERCONDMULTI="1";; # clear
        esac
        case $CURRWEATHERTEMPF in
                2*) TEMPMULTI=".25";;
                3*) TEMPMULTI=".5";;
                4*) TEMPMULTI=".75";;
                5*) TEMPMULTI="1";;
                6*) TEMPMULTI="1";;
                7*) TEMPMULTI="1";;
                8*) TEMPMULTI=".75";;
                9*) TEMPMULTI=".50";;
                10*) TEMPMULTI=".25";;
        esac
        RAD=$(/usr/bin/bc -l -e "scale = 2; $BASERAD * $WEATHERCONDMULTI * $TEMPMULTI" -e quit | cut -d"." -f1)
        echo "Current weather: $CURRWEATHERDESC"
        echo "Current temperature: $CURRWEATHERTEMPF F"
        echo "Weather adapted search radius: $(/usr/bin/bc -l -e "scale = 2; $RAD / 1609.34" -e quit) miles"
        echo ""
        echo "Selection:"
}

# Yelp Stuff
# Find candidate restaurants from Yelp
FETCHLUNCH(){
	# Determine max number of open restaurants at this time within the radius defined by the weather conditions
        MAXOPEN=$(/usr/local/bin/curl -s -X GET "https://api.yelp.com/v3/businesses/search?limit=$LIMIT&latitude=$LAT&longitude=$LONG&radius=$RAD&open_now=true&categories=restaurants&term=lunch" \
                -H "Authorization: Bearer $YELPAPIKEY" \
                | /usr/local/bin/jq -rc ".total")

        # Set the random offset based on max number in that radius
        OFFSET="$(jot -r 1 1 $MAXOPEN)"

	# Query the Yelp API and return a randomly offset result matching our criteria
	# Note that minimum rating is defined here via JQ as Yelp's API doesn't have a filter term for it
        /usr/local/bin/curl -s -X GET "https://api.yelp.com/v3/businesses/search?limit=$LIMIT&latitude=$LAT&longitude=$LONG&radius=$RAD&open_now=true&offset=$OFFSET&categories=restaurants&term=lunch" -H "Authorization: Bearer $YELPAPIKEY" \
                | /usr/local/bin/jq -cr '.businesses[] | select ( .rating >= 3.0 )| .name, .rating, .review_count, .categories[].title, .location.display_address[]' \
                | tr "\n" "|" \
                | sed 's/\|/ stars\|/2;s/\|/ reviews\|/3' \
                | tr "|" "\n"
}

BUILDTEXT(){
        echo "To: $RECIPIENTS"
        echo "Subject: $THISSUBJECT"
        FETCHWEATHER
        FETCHLUNCH
        echo ""
        echo "Generated from $0"
}

###############################################################################
### EXECUTION

while getopts "e:h?" OPT; do
case $OPT in
        e) RECIPIENTS="$OPTARG" ;;
        h) USAGE ;;
        ?) USAGE ;;
        \?) USAGE ;;
esac
done

# If there are recipients defined, send an email to them
if [ -z $RECIPIENTS ]
then
        BUILDTEXT
else
        BUILDTEXT | /usr/sbin/sendmail -t
fi

###############################################################################
### CLEANUP, log, exit cleanly
# logger "$0 - Exited cleanly"
exit 0
