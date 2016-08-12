date=`date +%s`
time wget "$1/api/v1/entries.json?find[type]=sgv&find[date][\$gte]=1467331200000&count=10000" -O entries.$date.json
time wget "$1/api/v1/treatments.json?find[created_at][\$gte]=2016-07-01&count=10000" -O treatments.$date.json
time wget "$1/api/v1/devicestatus.json?find[created_at][\$gte]=2016-07-01&count=10000" -O devicestatus.$date.json
time tar cvzf nightscout.$date.tar.gz entries.$date.json treatments.$date.json devicestatus.$date.json
rm entries.$date.json treatments.$date.json devicestatus.$date.json
