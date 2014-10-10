require 'rails_helper'

describe ArtifactResolutionService do
  it { is_expected.to have_many_to_one :sso_descriptor }
end
