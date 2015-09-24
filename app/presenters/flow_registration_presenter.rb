class FlowRegistrationPresenter

  def initialize(flow)
    @flow = flow
    @i18n_prefix = "flow.#{@flow.name}"
  end

  def slug
    @flow.name
  end

  def need_id
    @flow.need_id
  end

  def content_id
    @flow.content_id
  end

  def title
    start_node.title
  end

  def paths
    ["/#{@flow.name}.json"]
  end

  def prefixes
    ["/#{@flow.name}"]
  end

  def description
    start_node.meta_description
  end

  NODE_PRESENTER_METHODS = [:title, :body, :hint]

  def indexable_content
    HTMLEntities.new.decode(
      text = @flow.questions.inject([start_node.body]) { |acc, node|
        pres = presenter_for(node)
        acc.concat(NODE_PRESENTER_METHODS.map { |method|
          begin
            pres.send(method)
          rescue I18n::MissingInterpolationArgument
            # We can't do much about this, so we ignore these text nodes
            nil
          end
        })
      }.compact.join(" ").gsub(/(?:<[^>]+>|\s)+/, " ")
    )
  end

  def state
    'live'
  end

private

  def presenter_for(node)
    case node
    when SmartAnswer::Question::Base
      QuestionPresenter.new(@i18n_prefix, node)
    when SmartAnswer::Outcome
      OutcomePresenter.new(@i18n_prefix, node)
    end
  end

  def start_node
    node = SmartAnswer::Node.new(@flow, @flow.name.underscore.to_sym)
    StartNodePresenter.new(@i18n_prefix, node)
  end
end
