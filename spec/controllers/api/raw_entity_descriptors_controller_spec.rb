require 'rails_helper'

RSpec.describe API::RawEntityDescriptorsController, type: :controller do
  describe 'post :create' do
    let(:entity_source) { create(:entity_source) }
    let(:source_tag) { entity_source.source_tag }

    def run
      request.env['HTTP_X509_DN'] = "CN=#{api_subject.x509_cn}" if api_subject
      post :create, tag: source_tag
      puts request.path
    end

    context 'not permitted' do
      let(:api_subject) { create(:api_subject) }
      before { run }
      subject { response }
      it { is_expected.to have_http_status(:forbidden) }
      it 'responds with a message' do
        data = JSON.load(response.body)
        expect(data['message']).to match(/explicitly denied/)
      end
    end

    context 'permitted' do
      let(:api_subject) { create(:api_subject, :authorized, permission: '*') }
      before { run }
      subject { response }
      it { is_expected.to have_http_status(:ok) }

      context 'with an entity source that does not exist' do
        let(:source_tag) { Faker::Lorem.word }
        it { is_expected.to have_http_status(:not_found) }
      end
    end
  end
end
