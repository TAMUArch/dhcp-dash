FactoryGirl.define do
  factory :user do
    email 'example@example.com'
    password 'password'
  end

  trait :admin_user do
    role 'admin'
  end

  trait :user_user do
    role 'user'
  end

  trait :spectator_user do
    role 'spectator'
  end
end

