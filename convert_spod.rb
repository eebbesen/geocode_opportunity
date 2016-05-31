require 'csv'
require 'geocoder'
require 'redis'
require 'byebug'

##
# Convert Socrata data to have separate lat/long columns
class ConvertSpod
  LATLONG_REGEX = /\((\d.*)\)/

  def initialize(filename,location_index,skip_geocoding)
    @filename = filename
    @location_index = location_index.to_i
    @skip_geocoding = skip_geocoding

    @nr = []
    Geocoder.configure(lookup: :google, timeout: 3, :cache => redis)
  end

  def convertCsv
    rows = CSV.readlines("data/#{@filename}")
    header = rows.shift
    @nr << (header + %w(LATITUDE LONGITUDE GEOCODER))
    rows.each do |row|
      new_row = lat_long_row row
      @nr << new_row
      print '.'
    end
    write_converted_file
  end

  private

  def redis
    @redis ||= Redis.new
  end

  def write_converted_file
    CSV.open("converted/#{@filename}", 'w') do |csv|
      @nr.each do |new_row|
        csv << new_row
      end
    end
  end

  def extract_latlong(address)
    if address.match(LATLONG_REGEX)
      latlong = address.match(LATLONG_REGEX)[1]
      [latlong.split(',')[0].strip, latlong.split(',')[1].strip, :extracted]
    else
      nil
    end
  end

  def geocode_address(address)
    return [nil,nil,:skipped] if @skip_geocoding
    cleansed = address_cleaner address
    begin
      Geocoder.coordinates(cleansed) + [Geocoder.config[:lookup]]
      sleep 0.22
    rescue StandardError => e
      puts "#{e.class}:#{e.message} for #{address}"
    end
  end

  def latlongify_address(address)
    lat_long = extract_latlong address
    lat_long ||= geocode_address address
  end
  
  def lat_long_row(row)
    new_row = row
    address = row[@location_index]
    # avoid geocoding rows with addresses known to be problematic
    if address.match(/details/i)
      puts "no address given for #{row}"
      redis.sadd('no_address', address)
    elsif lat_long = latlongify_address(address)
      new_row << lat_long[0]
      new_row << lat_long[1]
      new_row << lat_long[2]
    else
      new_row << nil
      new_row << nil
      new_row << :no_address
      puts "COULD NOT RESOLVE #{address}"
      redis.sadd('bad_address', address)
    end
    new_row
  end

  def address_cleaner(address)
    elements = address.match(/(.*)\s*-.*(.*)/).to_a
    if elements.size > 0
      elements.shift
      elements.join "\n"
    else
      address
    end
  end
end
