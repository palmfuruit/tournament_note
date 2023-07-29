FactoryBot.define do
  factory :elimination do
    association :tournament, :elimination
    sequence(:name) { |n| "トーナメント#{n}" }

    trait :with_teams do
      transient do
        num_of_teams { 4 }
      end

      after(:create) do |elimination, evaluator|
        FactoryBot.create_list(:team, evaluator.num_of_teams, tournament: elimination.tournament)
        elimination.tournament.set_entryNo
      end
    end

  end
end
