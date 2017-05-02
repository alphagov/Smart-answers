module SmartAnswer
  class StartButton
    def initialize(smart_answer, view)
      @smart_answer = smart_answer.to_sym
      @view = view
    end

    def text
      if customized_start_button?
        custom_text_and_link[@smart_answer][:text]
      else
        "Start now"
      end
    end

    def href
      if customized_start_button?
        custom_text_and_link[@smart_answer][:href]
      else
        @view.smart_answer_path(@smart_answer.to_s, started: "y")
      end
    end

  private

    def customized_start_button?
      custom_text_and_link.has_key?(@smart_answer)
    end

    def custom_text_and_link
      {
        "calculate-your-child-maintenance": {
          text: "Calculate your child maintenance",
          href: "/calculate-your-child-maintenance/y"
        }
      }
    end
  end
end
