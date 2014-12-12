require 'rails_helper'

RSpec.describe API::APIController, type: :controller do
    controller do
      def good
        check_access!('permit')
        render nothing: true
      end

      def bad
        render nothing: true
      end

      def public
        public_action
        render nothing: true
      end

      def failed
        check_access!('deny')
        render nothing: true
      end
    end

  it 'acts as basis', focus: true do
    expect(controller).to be_a_kind_of(API::APIController)
  end

  context 'after_action hook' do
    before do
      @routes.draw do
        get '/anonymous/good' => 'anonymous#good'
        get '/anonymous/bad' => 'anonymous#bad'
        get '/anonymous/public' => 'anonymous#public'
        get '/anonymous/failed' => 'anonymous#failed'
        get '/anonymous/force_authn' => 'anonymous#force_authn'
      end
    end

    it 'allows an action with access control', focus: true do
      expect { get :good }.not_to raise_error
    end

    it 'fails without access control' do
      msg = 'No access control performed by AnonymousController#bad'
      expect { get :bad }.to raise_error(msg)
    end

    it 'allows a public action' do
      expect { get :public }.not_to raise_error
    end
  end
end
