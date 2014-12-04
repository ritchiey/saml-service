FactoryGirl.define do
  factory :basic_federation, parent: :entities_descriptor,
                             traits: [:with_publication_info] do

    # Services
    after :create do | ed |
      ed.add_entity_descriptor create_idp(ed)
      ed.add_entity_descriptor create_idp(ed)

      ed.add_entity_descriptor create_sp(ed)
      ed.add_entity_descriptor create_sp(ed)

      ed.add_entity_descriptor create_aa(ed)
    end
  end
end

def create_idp(entities_descriptor)
  ed = create :entity_descriptor,
              :with_registration_info,
              :with_entity_attribute,
              entities_descriptor: entities_descriptor

  ed.add_idp_sso_descriptor create :idp_sso_descriptor,
                                   :with_ui_info, entity_descriptor: ed

  ed.add_attribute_authority_descriptor create :attribute_authority_descriptor,
                                               entity_descriptor: ed

  ed
end

def create_sp(entities_descriptor)
  ed = create :entity_descriptor,
              :with_registration_info,
              :with_refeds_rs_entity_category,
              entities_descriptor: entities_descriptor

  ed.add_sp_sso_descriptor create :sp_sso_descriptor, :request_attributes,
                                  :with_ui_info, entity_descriptor: ed

  ed
end

def create_aa(entities_descriptor)
  ed = create :entity_descriptor,
              :with_registration_info,
              :with_entity_attribute,
              entities_descriptor: entities_descriptor

  ed.add_attribute_authority_descriptor create :attribute_authority_descriptor,
                                               entity_descriptor: ed

  ed
end
