FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com"}   
    password "foobar"
    password_confirmation "foobar"

    factory :admin do
      admin true
    end
  end
  factory :micropost do
    content "Lorem ipsum"
    user
  end

  factory :season do
    #year 2013
    sequence(:year)  { |n| 2012 + n }
  end
end
