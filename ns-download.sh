time wget "$1/api/v1/entries.json?find[type]=sgv&find[date][\$gte]=1467331200000&count=10000"
time wget "$1/api/v1/treatments.json?find[created_at][\$gte]=2016-07-01&count=10000"
time wget "$1/api/v1/devicestatus.json?find[created_at][\$gte]=2016-07-01&count=10000"
time tar cvzf nightscout.tar.gz *.json*find*
rm 'entries.json?find[type]=sgv&find[date][$gte]=1467331200000&count=10000'
rm 'treatments.json?find[created_at][$gte]=2016-07-01&count=10000'
rm 'devicestatus.json?find[created_at][$gte]=2016-07-01&count=10000'
