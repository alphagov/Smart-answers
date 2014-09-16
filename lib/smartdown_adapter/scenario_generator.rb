module SmartdownAdapter
  class ScenarioGenerator

    def initialize(question_name, answer_combinations)
      @question_name = question_name
      @answer_combinations = answer_combinations
      @errors = []
      @answer_hashes = {}
      @outcomes = 0
    end

    def perform
      smartdown_flow = Registry.instance.find(@question_name)
      combinations = generate_start_combinations(smartdown_flow)
      until combinations.empty? do
        combinations = generate_next_combinations(smartdown_flow, combinations)
      end
      p "#{@outcomes} combinations generated"
      p "#{@errors.count} errors"
    end

  private

    def generate_start_combinations(smartdown_flow)
      state = smartdown_flow.state(true, [])
      questions = state.current_node.elements.select do |element|
        element.class.to_s.include?("Smartdown::Model::Element::Question")
      end
      question_keys = questions.map(&:name).map(&:to_sym)
      answer_combinations(question_keys)
    end

    def generate_next_combinations(smartdown_flow, combinations)
      new_combinations = []
      combinations.each_with_index do |combination, combination_index|
        answers = combination.map do |hash|
          hash.values.first
        end
        begin
          state = smartdown_flow.state(true, answers)
          if state.current_node.is_a? Smartdown::Api::QuestionPage
            questions = state.current_node.elements.select do |element|
              element.class.to_s.include?("Smartdown::Model::Element::Question")
            end
            question_keys = questions.map(&:name).map(&:to_sym)
            answer_combinations = answer_combinations(question_keys)
            answer_combinations.each do |answer_combination|
              new_combinations << combination + answer_combination
            end
          else
            combination.each do |comb|
              @outcomes += 1
              p comb
            end
            p state.current_node.name
            p "======================="
          end
        rescue Exception
          @errors << combination
        end
      end
      new_combinations
    end

    def answer_combinations(question_keys)
      @answer_hashes[question_keys] || generate_answer_combinations(question_keys)
    end

    def generate_answer_combinations(question_keys)
      combinations = []
      first_question_answers = @answer_combinations.fetch(question_keys.first)
      first_question_answers.each do |answer|
        combinations << [{ question_keys.first => answer }]
      end
      question_keys.last(question_keys.length-1).each do |question_key|
        answers = @answer_combinations.fetch(question_key)
        new_combinations = []
        combinations.each do |combination|
          answers.each do |answer|
            new_combinations << combination + [{ question_key => answer }]
          end
        end
        combinations = new_combinations
      end
      @answer_hashes[question_keys] = combinations
      combinations
    end
  end
end
