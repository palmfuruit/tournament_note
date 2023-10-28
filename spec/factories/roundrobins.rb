FactoryBot.define do
  factory :roundrobin do
    association :tournament, :roundrobin
    sequence(:name) { |n| "リーグ#{n}" }
    has_score { false }
    rank1 { :win_points }
    rank2 { :none }
    rank3 { :none }
    rank4 { :none }


    trait :with_teams do
      transient do
        num_of_teams { 4 }
      end

      after(:create) do |roundrobin, evaluator|
        FactoryBot.create_list(:team, evaluator.num_of_teams, tournament: roundrobin.tournament)
        roundrobin.tournament.set_entryNo
      end
    end

  end
end
