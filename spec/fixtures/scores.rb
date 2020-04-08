survey "Scores" do
  section_colors "Supported Questions" do
    label "These questions are examples that support scoring"

    question "What is your favorite color?", {reference_identifier: "1", pick: :one}
    answer "red",   {reference_identifier: "r", data_export_identifier: "1"}
    answer "blue",  {reference_identifier: "b", data_export_identifier: "2"}
    answer "green", {reference_identifier: "g", data_export_identifier: "3"}
    answer :other

    q_2b "Choose the colors you don't like", :pick => :any
    a_1 "orange", :display_order => 1
    a_2 "purple", :display_order => 2
    a_3 "brown", :display_order => 0
    a :omit

    group "scoring in sub questions" do
      question "What is your favorite animal?", {reference_identifier: "2", pick: :one}
      answer "dog",   {reference_identifier: "d", data_export_identifier: "1"}
      answer "cat",  {reference_identifier: "c", data_export_identifier: "2"}
      answer "bird", {reference_identifier: "bi", data_export_identifier: "3"}

      q_3b "Choose the animals you don't like", :pick => :any
      a_4 "reptile", :display_order => 1
      a_5 "rodent", :display_order => 2
    end
  end

end
