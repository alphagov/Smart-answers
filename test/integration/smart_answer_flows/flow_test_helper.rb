# encoding: UTF-8

module FlowTestHelper
  def setup_for_testing_flow(flow_slug)
    @flow = SmartAnswer::FlowRegistry.instance.find(flow_slug)
    @responses = []
  end

  def add_response(resp)
    @responses << resp.to_s
  end

  def current_state
    @state ||= begin
      @flow.process(@responses)
    end
  end

  def outcome_body
    @outcome_body ||= begin
      presenter = OutcomePresenter.new("flow.#{@flow.name}", @flow.node(current_state.current_node), current_state)
      Nokogiri::HTML::DocumentFragment.parse(presenter.body)
    end
  end

  def assert_current_node(node_name, opts = {})
    assert_equal node_name, current_state.current_node
    assert @flow.node_exists?(node_name), "Node #{node_name} does not exist."
    opts[:error] ? assert_current_node_is_error : assert_not_error
  end

  def assert_current_node_is_error(message = nil)
    assert current_state.error, "Expected #{current_state.current_node} to be in error state"
    assert_equal message, current_state.error if message
  end

  def assert_not_error
    assert current_state.error.nil?, "Unexpected Flow error: #{current_state.error}"
  end

  def assert_state_variable(name, expected, options = {})
    actual = current_state.send(name)
    if options[:round_dp]
      expected = sprintf("%.#{options[:round_dp]}f", expected)
      actual = sprintf("%.#{options[:round_dp]}f", actual)
    end
    assert_equal expected, actual
  end

  def assert_phrase_list(variable_name, expected_keys)
    phrase_list = current_state.send(variable_name)
    assert phrase_list.is_a?(SmartAnswer::PhraseList), "State variable #{variable_name} is not a PhraseList"
    assert_equal expected_keys, phrase_list.phrase_keys
  end

  def assert_calendar
    assert @flow.node(current_state.current_node).evaluate_calendar(current_state).present?
  end

  def assert_calendar_date(expected_date_or_range)
    calendar = @flow.node(current_state.current_node).evaluate_calendar(current_state)
    assert calendar.dates.select {|event| event.date == expected_date_or_range }.any?
  end
end
