FactoryBot.define do
  factory :game do
    association :elimination
    round { 1 }
    gameNo { 1 }
  end
end
