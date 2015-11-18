require 'rails_helper'
require Rails.root.join('bin/sync').to_s

RSpec.describe 'bin/sync' do
  let(:fr_source) { create(:federation_registry_source) }
  let(:tag) { Faker::Lorem.word }

  it 'invokes the job' do
    expect(UpdateFromFederationRegistry).to receive(:perform)
      .with(id: fr_source.id, primary_tag: tag)
    SyncCLI.perform(fr_source.hostname, tag)
  end
end
