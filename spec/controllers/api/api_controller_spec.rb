require 'rails_helper'

RSpec.describe API::APIController, type: :controller do
  controller(API::APIController) do
    def an_action
      check_access!('required:permission')
      render nothing: true
    end

    def bad_action
      render nothing: true
    end

    def public
      public_action
      render nothing: true
    end
  end

  before do
    @routes.draw do
      get '/anonymous/an_action' => 'api/api#an_action'
      get '/anonymous/bad_action' => 'api/api#bad_action'
      get '/anonymous/public' => 'api/api#public'
    end
  end

  it 'acts as basis' do
    expect(controller).to be_a_kind_of(API::APIController)
  end

  context '#after_action' do

    subject(:api_subject) { create :api_subject }

    before do
      request.env['HTTP_X509_DN'] = api_subject.x509_dn
    end

    shared_examples '#after_action base' do
      it 'fails request to incorrectly implemented action' do
        msg = 'No access control performed by API::APIController#bad_action'
        expect { get :bad_action }.to raise_error(msg)
      end

      it 'completes request to a public action' do
        get :public
        expect(response).to have_http_status(:ok)
      end
    end

    context 'subject without permissions' do
      has_behavior '#after_action base'

      it 'fails request when permissions checked' do
        get :an_action
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'subject with invalid permissions' do
      subject(:api_subject) do
        create :api_subject, :authorized, permission: 'invalid:permission'
      end

      has_behavior '#after_action base'

      it 'has an invalid permission' do
        expect(subject.permissions).to eq(['invalid:permission'])
      end

      it 'fails request when permissions checked' do
        get :an_action
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'subject with valid permission' do
      subject(:api_subject) do
        create :api_subject, :authorized, permission: 'required:permission'
      end

      has_behavior '#after_action base'

      it 'has the valid permission' do
        expect(subject.permissions).to eq(['required:permission'])
      end

      it 'completes request after permissions checked' do
        get :an_action
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
