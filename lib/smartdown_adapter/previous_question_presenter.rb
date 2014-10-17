module SmartdownAdapter
  class PreviousQuestionPresenter
    extend Forwardable

    def_delegators :@smartdown_previous_question, :title

    def initialize(smartdown_previous_question)
      @smartdown_previous_question = smartdown_previous_question
    end

    #TODO
    def multiple_responses?
      false
    end

    def response_label(response_key)
      case smartdown_previous_question.question
        when Smartdown::Api::MultipleChoice
          smartdown_previous_question.options.find{|option| option.value == response_key}.label
        when Smartdown::Api::DateQuestion
          #TODO: formatting date here until we return answer object as part of previous question object
          #and we can use the smartdown humanize methods
          Date.parse(response_key).strftime("%-d %B %Y")
        when Smartdown::Api::SalaryQuestion
          salary_array = response_key.split("-")
          "#{salary_array[0]} per #{salary_array[1]}"
        when Smartdown::Api::TextQuestion
          response_key
      end
    end

  private
    attr_reader :smartdown_previous_question

  end
end
