module TeamsHelper

  def div_tag__uniform_radio_btn(form, color, team_id)
    tag.div(class: ["form-check", "form-check-inline"]) {
      concat form.radio_button(:color, color, id: "team_color_#{team_id}_#{color}", class: "form-check-input")
      concat form.label(:color, class: "form-check-label", value: "#{team_id}_#{color}") {
        concat uniform(color)
      }
    }
  end


end
