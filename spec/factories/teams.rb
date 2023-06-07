FactoryBot.define do
  factory :team do
    association :elimination
    sequence(:name) { |n| "Team#{n}" }
  end
end
