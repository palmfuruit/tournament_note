class TeamDecorator < ApplicationDecorator
  include ApplicationHelper

  delegate_all

  def div_tag__uniform_radio_btn(form, color)
    tag.div(class: ["form-check", "form-check-inline"]) {
      concat form.radio_button(:color, color, id: "team_color_#{id}_#{color}", class: "form-check-input")
      concat form.label(:color, class: "form-check-label", value: "#{id}_#{color}") {
        concat uniform(color)
      }
    }
  end
end
