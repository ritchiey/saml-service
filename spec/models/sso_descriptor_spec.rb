require 'rails_helper'

describe SSODescriptor do
  context 'extends role_descriptor' do
    context 'optional attributes' do
      it { is_expected.to have_one_to_many :artifact_resolution_services }
      it { is_expected.to have_one_to_many :single_logout_services }
      it { is_expected.to have_one_to_many :manage_name_id_services }
      it { is_expected.to have_one_to_many :name_id_formats }
    end
  end
end
