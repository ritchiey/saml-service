FactoryGirl.define do
  factory :mdui_description, class: 'MDUI::DisplayName',
                             parent: :localized_name do
    association :ui_info, factory: :mdui_ui_info
  end
end
