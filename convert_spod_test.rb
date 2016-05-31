require "minitest/autorun"
require "./convert_spod"

class ConvertSpodSubject < ConvertSpod
  def initialize
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

end