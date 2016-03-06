### Scripts to convert data from Socrata format to CartoDB format.

Socrata files from https://information.stpaul.gov/ have the latitude and longitude embedded in the location field.
This script extracts those values into new latitude and longitude fields.
CartoDB automotically recognizes the latitude and longitude fields when the converted file is uploaded.



# How to use
1. Download Socrata data in CSV format
1. Place downloaded file in this project's `data` directory
1. Identify index of the location column in downloaded file
  1. Index is zero-based note that the tenth column has an index value of 9, for example
1. Run script passing in the filename and location column index, respectively
  1. `ruby convert_spod.rb Public_Buildings_-_Dataset-saint_paul-03.05.16.csv 9`
1. Converted file of the same name will be generated in this project's `converted` directory



# etc.
## What about records that don't have lat/long in the location field?
Some records don't have lat/long as part of the location.  Some entire datasets don't have lat/long as part of the location since the address is not specific enough (crime incidents have the last digit of the street address exed out, for example).

Currently these records are printed to the console prepended with `NO LAT/LONG FOUND FOR`.

In the future I hope to use the address to grab the latitude and longitide.

### This script was developed during the [March 2016 Geo:Code 2.0](http://www.hennepin.us/geocode) code-a-thon.