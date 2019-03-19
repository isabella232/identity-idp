require 'rails_helper'

describe AccountReset::RecoverController do
  let(:user) { build(:user, :with_authentication_app, :with_email) }
  before do
    allow_any_instance_of(UserDecorator).to receive(:identity_verified?).and_return(true)
  end

  describe '#show' do
    it 'renders the page' do
      stub_sign_in_before_2fa(user)

      get :show

      expect(response).to render_template(:show)
    end

    it 'redirects to root if user not signed in' do
      get :show

      expect(response).to redirect_to root_url
    end

    it 'redirects to 2FA setup url if 2FA not set up' do
      stub_sign_in_before_2fa
      get :show

      expect(response).to redirect_to two_factor_options_url
    end

    it 'logs the visit to analytics' do
      stub_sign_in_before_2fa(user)
      stub_analytics

      expect(@analytics).to receive(:track_event).with(Analytics::IAL2_RECOVERY_REQUEST_VISITED)

      get :show
    end
  end

  describe '#create' do
    it 'logs totp user in the analytics' do
      stub_sign_in_before_2fa(user)

      stub_analytics
      attributes = {
        event: 'request',
        sms_phone: false,
        totp: true,
        piv_cac: false,
        email_addresses: 0,
      }
      expect(@analytics).to receive(:track_event).
        with(Analytics::IAL2_RECOVERY_REQUEST, attributes)

      post :create
    end

    it 'logs sms user in the analytics' do
      TwilioService::Utils.telephony_service = FakeSms
      user = build(:user, :signed_up, :with_email)
      stub_sign_in_before_2fa(user)

      stub_analytics
      attributes = {
        event: 'request',
        sms_phone: true,
        totp: false,
        piv_cac: false,
        email_addresses: 0,
      }
      expect(@analytics).to receive(:track_event).
        with(Analytics::IAL2_RECOVERY_REQUEST, attributes)

      post :create
    end

    it 'logs PIV/CAC user in the analytics' do
      user = build(:user, :with_piv_or_cac, :with_email)
      stub_sign_in_before_2fa(user)

      stub_analytics
      attributes = {
        event: 'request',
        sms_phone: false,
        totp: false,
        piv_cac: true,
        email_addresses: 0,
      }
      expect(@analytics).to receive(:track_event).
        with(Analytics::IAL2_RECOVERY_REQUEST, attributes)

      post :create
    end

    it 'redirects to root if user not signed in' do
      post :create

      expect(response).to redirect_to root_url
    end

    it 'redirects to 2FA setup url if 2FA not set up' do
      stub_sign_in_before_2fa
      post :create

      expect(response).to redirect_to two_factor_options_url
    end
  end
end