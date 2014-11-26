FactoryGirl.define do
  factory :mdui_geolocation_hint, class: 'MDUI::GeolocationHint' do
    uri { "geo:#{Faker::Number.number(3)},#{Faker::Number.number(3)}" }
    association :disco_hints, factory: :mdui_disco_hint
  end

end
