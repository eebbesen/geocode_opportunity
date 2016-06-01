require "minitest/autorun"
require "./convert_spod"

class ConvertSpodSubject < ConvertSpod
  def initialize
  end

  def skip_geocoding=(val)
    @skip_geocoding = val
  end
end

class ConvertSpodTest < Minitest::Test
  def setup
    @converter = ConvertSpodSubject.new
    @address = %q{
      1600 GRAND AVE
      Saint Paul, MN
      (44.9378926, -93.1690434)
    }
  end

  def test_extract_latlong
    res = @converter.send(:extract_latlong, @address)
    assert_equal ["44.9378926", "-93.1690434", :extracted], res
  end

  def test_extract_latlong_empty
    assert_equal nil, @converter.send(:extract_latlong, '')
  end

  def test_extract_latlong_no_latlong
    assert_equal nil, @converter.send(:extract_latlong, '1600 GRAND AVE')
  end

  def test_extract_latlong_needs_stripping
    res = @converter.send(:extract_latlong, "\n  (44.9378926 ,   -93.1690434)")
    assert_equal ["44.9378926", "-93.1690434", :extracted], res
  end

  def test_geocode_address_skip_geocoding
    @converter.skip_geocoding = true

    assert_equal [nil,nil,:skipped], @converter.send(:geocode_address, @address)
  end

  def test_geocode_address
    Geocoder.stub(:coordinates, ['lat', 'long']) do
      Geocoder.stub(:config, {lookup: :happy}) do
        assert_equal ['lat', 'long', :happy], @converter.send(:geocode_address, @address)
      end
    end
  end
end