status :draft

multiple_choice :q1? do
  option :yes
  option :no

  next_node do
    :done
  end
end

outcome :done
