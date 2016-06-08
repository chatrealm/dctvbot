# file: test/helpers/url_helper_test.rb

class UrlHelperTest < Minitest::Test
  def test_time_is_link
    time = DateTime.parse('14:00 EDT')
    assert_equal('http://time.is/1400_EDT', UrlHelper.time_is_link(time))
  end

  def test_time_is_link_with_day
    time = DateTime.parse('Jun 12 2016 14:00 EDT')
    assert_equal('http://time.is/1400_12_Jun_2016_EDT', UrlHelper.time_is_link(time, true))
  end
end
