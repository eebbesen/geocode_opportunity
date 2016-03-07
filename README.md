### Script to convert data from Socrata format to CartoDB format

Socrata files from https://information.stpaul.gov/ have the latitude and longitude embedded in the location field.
This script extracts those values into new latitude and longitude fields.
CartoDB automotically recognizes the latitude and longitude fields.

# Prerequisites
* `brew install redis`
* `gem install redis`
* `gem install geocoder`

# How to use
1. Download Socrata data in CSV format
1. Place downloaded file in this project's `data` directory
1. Identify index of the location column in downloaded file
  1. Index is zero-based note that the tenth column has an index value of 9, for example
1. Run script passing in the filename and location column index, respectively
  1. `ruby convert_spod.rb Public_Buildings_-_Dataset-saint_paul-03.05.16.csv 9` to allow geocoding attempts
  1. `ruby convert_spod.rb Public_Buildings_-_Dataset-saint_paul-03.05.16.csv 9 skip` to NOT allow geocoding attempts
1. Converted file of the same name will be generated in this project's `converted` directory
1. `redis-cli smembers bad_address` will show distinct addresses that were problematic
1. `redis-cli smembers no_address` will show distinct addresses that didn't contain any geographic information

Rows that cannot be resolved to lat/long will be written the converted file in their original format, but will have empty entries for latitude and longituded added

# Accuracy
Please be aware that some addresses are interpreted differently by different geocoding services.  Sometimes the results are simply incorrect.  Please take care when using this data to understand that the geocoding services may have picked the wrong location.
* `:google` does a pretty good job of interpolating addresses that are not standard (intersections, 'I-94 between Lexington and Hamline', etc.)
* `:geocoder_ca` will pick a point in the city if that's all it can figure out (e.g. 44.9537029, -93.0899578 for Saint Paul)

For example, `I-35E south of exit #110. west side of I-35E.\nSt Paul, MN` was incorrectly interpretted by all services I tried.

# etc.
## What about records that don't have lat/long in the location field?
Some records don't have lat/long as part of the location.  Some entire datasets don't have lat/long as part of the location since the address is not specific enough (crime incidents have the last digit of the street address exed out, for example).

I've elected to offer the use [Geocoder](https://github.com/alexreisner/geocoder) to resolve these addresses, but you can disable this by passing a third argument to the script.

Records that cannot be geocoded successfully, or that don't have lat/long and you opt out of geocoding, are printed to the console prepended with `NO LAT/LONG FOUND FOR`.


## Geocoder API Issues
You can configure Geocoder to use different services depending on how fast you need to go, whether you're geting rate limited, etc.  See [Geocoder documentation](https://github.com/alexreisner/geocoder) for details.  The the important note on accuracy above.

### Limits
Different geocoding services have different limits (calls per day, calls per second) which are pretty low unless you pay.

### Skipping Geocoding
If you provide a third parameter to the script (e.g., `ruby convert_spod.rb Public_Buildings_-_Dataset-saint_paul-03.05.16.csv 9 blah`) it will not attempt to use the Geocoder gem to discover lat/long for an address.  Use this if you are having issues with one or more geocoder services (throttling, other errors, etc.).


### This script was developed during the [March 2016 Geo:Code 2.0](http://www.hennepin.us/geocode) code-a-thon.