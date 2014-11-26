FactoryGirl.define do
  factory :mdui_logo, class: 'MDUI::Logo' do
    uri { Faker::Internet.url }
    width { Faker::Number.number(3) }
    height { Faker::Number.number(3) }
    association :ui_info, factory: :mdui_ui_info
  end
end
