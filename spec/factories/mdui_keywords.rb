FactoryGirl.define do
  factory :mdui_keywords, class: 'MDUI::Keywords' do
    lang { 'en' }
    association :ui_info, factory: :mdui_ui_info
  end
end
