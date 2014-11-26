FactoryGirl.define do
  factory :mdui_logo, class: 'MDUI::Logo' do
    uri { Faker::Internet.url }
    width { Faker::Number.number(3).to_i + 1 }
    height { Faker::Number.number(3).to_i + 2 }
    association :ui_info, factory: :mdui_ui_info
  end
end
