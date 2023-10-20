Capybara.configure do |config|
  config.automatic_label_click = true
end

Capybara.default_max_wait_time = 2
Capybara.add_selector(:test_id) do
  css { |val| %Q([data-testid*="#{val}"]) }
end