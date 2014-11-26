FactoryGirl.define do
  factory :mdui_ui_info, class: 'MDUI::UiInfo' do
    role_descriptor

    factory :mdui_ui_info_with_content do
      after(:create) do | ui_info |
        ui_info.add_display_name create :mdui_display_name
        ui_info.add_description create :mdui_description
        ui_info.add_keyword_list create :mdui_keyword_list_with_content
        ui_info.add_logo create :mdui_logo
        ui_info.add_information_url create :mdui_information_url
        ui_info.add_privacy_statement_url create :mdui_privacy_statement_url
      end
    end
  end
end
