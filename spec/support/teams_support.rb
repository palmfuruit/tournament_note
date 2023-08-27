def have_uniform_icon(color)
  if color.present?
    have_selector ".fa-shirt.uniform-#{color}"
  else
    have_selector ".fa-shirt"
  end
end

