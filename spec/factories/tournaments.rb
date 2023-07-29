FactoryBot.define do
  factory :tournament do

    trait :elimination do
      tournament_type { :elimination }
    end

    trait :roundrobin do
      tournament_type { :roundrobin }
    end

    trait :with_teams do
      transient do
        num_of_teams { 4 }
      end

      after(:create) do |tournament, evaluator|
        FactoryBot.create_list(:team, evaluator.num_of_teams, tournament: tournament)
        tournament.set_entryNo
      end
    end
  end
end
