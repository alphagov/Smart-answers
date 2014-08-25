require 'smartdown/api/flow'

module SmartdownAdapter
  class Registry

    def self.smartdown_questions
      smartdown_directory_path = Rails.root.join('lib', 'smartdown_flows')
      Dir.entries(smartdown_directory_path).select {|entry|
        File.directory? File.join(smartdown_directory_path, entry) and !(entry =='.' || entry == '..')
      }
    end

    def self.smartdown_transition_questions
      smartdown_questions.select { |smartdown_question_name|
        coversheet_path = Rails.root.join('lib', 'smartdown_flows', smartdown_question_name, "#{smartdown_question_name}.txt")
        input = Smartdown::Parser::DirectoryInput.new(coversheet_path)
        smartdown_flow = Smartdown::Api::Flow.new(input)
        smartdown_flow.transition?
      }
    end

    def self.check(name, options = FLOW_REGISTRY_OPTIONS)
      show_drafts = options.fetch(:show_drafts, false)
      show_transitions = options.fetch(:show_transitions, false)
      use_smartdown_question = false
      if self.smartdown_questions.include? name
        coversheet_path = Rails.root.join('lib', 'smartdown_flows', name, "#{name}.txt")
        input = Smartdown::Parser::DirectoryInput.new(coversheet_path)
        smartdown_flow = Smartdown::Api::Flow.new(input)
        use_smartdown_question = (smartdown_flow && smartdown_flow.draft? && show_drafts) ||
        (smartdown_flow && smartdown_flow.transition? && show_transitions) ||
        (smartdown_flow && smartdown_flow.published?)
      end
      use_smartdown_question
    end
  end
end
