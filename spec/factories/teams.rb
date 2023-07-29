FactoryBot.define do
  factory :team do
    association :tournament, :elimination
    sequence(:name) { |n| "Team#{n}" }
  end
end
