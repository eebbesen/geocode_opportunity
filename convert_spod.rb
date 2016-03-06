require 'csv'
require 'geocoder'
require 'redis'

##
# Convert Socrata data to have separate lat/long columns
class ConvertSpod
  def initialize(filename,location_index,skip_geocoding)
    @filename = filename
    @location_index = location_index.to_i
    @skip_geocoding = skip_geocoding

    @nr = []
    Geocoder.configure(lookup: :google, timeout: 3, :cache => redis)
  end

  def redis
    @redis ||= Redis.new
  end

  def latlongify_address(address)
    Geocoder.coordinates(address)
  rescue StandardError => e 
    puts "#{e.class}:#{e.message} for #{address}"
  end

  def write_converted_file
    CSV.open("converted/#{@filename}", 'w') do |csv|
      @nr.each do |new_row|
        csv << new_row
      end
    end
  end
  
  def lat_long_row(row)
    new_row = row
    address = row[@location_index]
    # avoid geocoding rows with addresses known to be problematic
    if address.match(/details/i)
      puts "no address given for #{row}"
      redis.sadd('no_address', address)
    elsif address.match(/\n\((\d.*)\)/)
      latlong = address.match(/\n\((\d.*)\)/)[1]
      new_row << latlong.split(',')[0].strip
      new_row << latlong.split(',')[1].strip
    elsif !@skip_geocoding && (latlong = latlongify_address(address)) 
      new_row << latlong[0]
      new_row << latlong[1]
      puts "got #{latlong} for #{address}"
      sleep 0.22 # to avoid API limit :(
    else
      new_row << nil
      new_row << nil
      puts "COULD NOT RESOLVE #{address}"
      redis.sadd('bad_address', address)
    end
    new_row
  end

  def convertCsv
    rows = CSV.readlines("data/#{@filename}")
    header = rows.shift
    @nr << (header + %w(LATITUDE LONGITUDE))
    rows.each do |row|
      new_row = lat_long_row row
      @nr << new_row
      print '.'
    end
    write_converted_file
  end
end

# 0: filename
# 1: location index
# 2: 'skip' to avoid geocoding attempt (optional)
ConvertSpod.new(ARGV[0], ARGV[1], ARGV[2]).convertCsv


