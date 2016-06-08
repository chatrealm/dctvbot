# file: test/helpers/message_helper_test.rb

require 'test_helper'

require 'helpers/message_helper'

class MessageHelperTest < Minitest::Test
  def setup
  end

  def test_replace_first_message_section
    before = 'one | two'
    after = MessageHelper.replace_first_message_section(before, 'three')
    assert_equal('three | two', after)
  end

  def test_replace_first_message_section_with_alternate_delimiter
    before = 'one - two'
    after = MessageHelper.replace_first_message_section(before, 'three', '-')
    assert_equal('three - two', after)
  end
end
