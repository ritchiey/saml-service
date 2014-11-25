FactoryGirl.define do
  factory :mdui_logo, class: 'MDUI::Logo', parent: :localized_uri do
    width { Faker::Number.number(3) }
    height { Faker::Number.number(3) }
    association :ui_info, factory: :mdui_ui_info
  end
end
