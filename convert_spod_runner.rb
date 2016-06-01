require 'convert_spod'

# 0: filename
# 1: location index
# 2: 'skip' to avoid geocoding attempt (optional)
puts 'Must supply a filename and index of location column' unless ARGV.size > 1
ConvertSpod.new(ARGV[0], ARGV[1], ARGV[2]).convertCsv


