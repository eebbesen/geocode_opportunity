require 'csv'
require 'byebug'
##
# Convert Socrata data to have separate lat/long columns
class ConvertSpod
  def initialize(filename)
    @filename = filename
  end

  def convertCsv(field_to_convert)
    nr = []
    rows = CSV.readlines("data/#{@filename}")
    header = rows.shift
    header += %w(LATITUDE LONGITUDE)
    nr << header
    rows.each do |row|
      to_convert = row[field_to_convert]
      if to_convert.match(/\n\((\d.*)\)/)
        latlong = to_convert.match(/\n\((\d.*)\)/)[1]
        row << latlong.split(',')[0].strip
        row << latlong.split(',')[1].strip
        nr << row
      else
        puts "NO LAT/LONG FOUND FOR #{row}"
      end
    end
    CSV.open("converted/#{@filename}", 'w') do |csv|
      nr.each do |new_row|
        csv << new_row
      end
    end
  end
end

fn = ARGV[0]
location_index = ARGV[1]
cs = ConvertSpod.new(fn)
cs.convertCsv location_index.to_i