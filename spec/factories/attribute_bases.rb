require 'faker'

FactoryGirl.define do
  factory :attribute_basis, class: 'AttributeBase' do
    name { Faker::Lorem.word }
    legacy_name { 'urn:oid:' + Faker::Base.numerify('#.#.#.#.#.#.#.#.#.#.#') }
    oid { Faker::Base.numerify('#.#.#.#.#.#.#.#.#.#.#') }
    description { Faker::Lorem.sentence }
    admin_restricted false
    specification_required false

    association :name_format, factory: :attribute_name_saml_uri
  end
end
