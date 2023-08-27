module TeamsHelper

  def div_tag__uniform_radio_btn(form, color, team_id)
    tag.div(class: ["form-check", "form-check-inline"]) {
      concat form.radio_button :color, color, id: "team_color_#{color}#{team_id}", class: "form-check-input"
      concat form.label(:color, class: "form-check-label", value:  "#{color}#{team_id}") {
        concat uniform(color)
      }
    }
  end


end
