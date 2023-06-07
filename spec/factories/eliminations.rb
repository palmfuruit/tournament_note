FactoryBot.define do
  factory :elimination do
    sequence(:name) { |n| "トーナメント#{n}"}

    trait :with_teams do
      transient do
        num_of_teams { 4 }
      end

      after(:create) do |elimination, evaluator|
        FactoryBot.create_list(:team, evaluator.num_of_teams, elimination: elimination)
        elimination.set_entryNo
      end
    end

  end
end
