require_relative '../test_helper'

module SmartAnswer
  class OutcomeHelperTest < ActiveSupport::TestCase
    include ActionView::Helpers::NumberHelper
    include OutcomeHelper

    test "#format_money doesn't add pence for amounts in whole pounds" do
      assert_equal '£1', format_money('1.00')
    end

    test "#format_money adds pence for amounts that aren't whole pounds" do
      assert_equal '£1.23', format_money('1.23')
    end
  end
end
