FactoryGirl.define do
  factory :mdui_keyword_list, class: 'MDUI::KeywordList' do
    lang { 'en' }
    association :ui_info, factory: :mdui_ui_info

    factory :mdui_keyword_list_with_content do
      content { "#{Faker::Lorem.words(6).join(' ')}" }
    end
  end
end
