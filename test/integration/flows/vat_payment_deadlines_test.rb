# encoding: UTF-8
require_relative '../../test_helper'
require_relative 'flow_test_helper'

class VatPaymentDeadlinesTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    WebMock.stub_request(:get, WorkingDays::BANK_HOLIDAYS_URL).
      to_return(:body => File.open(fixture_file('bank_holidays.json')))
    setup_for_testing_flow 'vat-payment-deadlines'
  end

  should "ask when your VAT accounting period ends" do
    assert_current_node :when_does_your_vat_accounting_period_end?
  end

  context "invalid dates" do
    should "show error with non end-of-month date" do
      add_response '2013-05-30'
      assert_current_node :when_does_your_vat_accounting_period_end?, :error => true
    end

    should "handle leap years correctly" do
      add_response '2012-02-28'
      assert_current_node :when_does_your_vat_accounting_period_end?, :error => true
    end
  end

  context "given a date that's the end of a month" do
    setup do
      add_response '2013-04-30'
    end

    should "ask how you want to pay" do
      assert_current_node :how_do_you_want_to_pay?
    end

    should "give result for Direct debit" do
      add_response 'direct-debit'
      assert_current_node :result_direct_debit
      assert_state_variable :last_dd_setup_date, "5 June 2013"
      assert_state_variable :funds_taken, "12 June 2013"
    end

    should "give result for online or telephone banking" do
      add_response 'online-telephone-banking'
      assert_current_node :result_online_telephone_banking
      assert_state_variable :last_payment_date, "7 June 2013"
    end

    should "give result for online debit or credit card" do
      add_response 'online-debit-credit-card'
      assert_current_node :result_online_debit_credit_card
      assert_state_variable :last_payment_date, "4 June 2013"
      assert_state_variable :funds_received_by, "7 June 2013"
    end

    should "give result for BACS Direct Credit" do
      add_response 'bacs-direct-credit'
      assert_current_node :result_bacs_direct_credit
      assert_state_variable :last_payment_date, "4 June 2013"
      assert_state_variable :funds_received_by, "7 June 2013"
    end

    should "give result for Bank Giro" do
      add_response 'bank-giro'
      assert_current_node :result_bank_giro
      assert_state_variable :last_payment_date, "4 June 2013"
      assert_state_variable :funds_received_by, "7 June 2013"
    end

    should "give result for CHAPS" do
      add_response 'chaps'
      assert_current_node :result_chaps
      assert_state_variable :last_payment_date, "11 June 2013"
      assert_state_variable :funds_received_by, "11 June 2013"
    end

    should "give result for Cheque" do
      add_response 'cheque'
      assert_current_node :result_cheque
      assert_state_variable :last_posting_date, "22 April 2013"
      assert_state_variable :funds_cleared_by, "30 April 2013"
    end
  end
end
