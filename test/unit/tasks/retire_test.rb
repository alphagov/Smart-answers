require 'test_helper'

class RetireSmartAnswerRakeTest < ActiveSupport::TestCase
  context "retire:smart_answer rake task" do
    setup do
      Rake::Task["retire:smart_answer"].reenable
    end

    should "raise exception when content_id isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:smart_answer"].invoke
      end

      assert_equal "Missing content_id parameter", exception.message
    end

    should "raise exception when base_path isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:smart_answer"].invoke("content-id", nil)
      end

      assert_equal "Missing base_path parameter", exception.message
    end

    should "raise exception when destination isn't supplied" do
      exception = assert_raises RuntimeError do
        Rake::Task["retire:smart_answer"].invoke(
          "content-id",
          "/base-path",
          nil
        )
      end

      assert_equal "Missing destination parameter", exception.message
    end

    should "invoke the unpublish, redirect_smart_answer and remove_smart_answer_from_search methods from ContentItemPublisher" do
      content_item_publisher_mock = ContentItemPublisher.any_instance

      content_item_publisher_mock.stubs(:unpublish).returns(nil)
      content_item_publisher_mock.stubs(:redirect_smart_answer).returns(nil)
      content_item_publisher_mock.stubs(:remove_smart_answer_from_search)
        .returns(nil)

      content_item_publisher_mock.expects(:unpublish).with("content-id").once
      content_item_publisher_mock.expects(:redirect_smart_answer)
        .with("/base-path", "/new-destination").once
      content_item_publisher_mock.expects(:remove_smart_answer_from_search)
        .with("/base-path").once

      Rake::Task["retire:smart_answer"].invoke(
        "content-id",
        "/base-path",
        "/new-destination"
      )
    end
  end
end
