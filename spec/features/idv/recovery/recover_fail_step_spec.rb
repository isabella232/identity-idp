require 'rails_helper'

feature 'recovery doc fail step' do
  include IdvStepHelper
  include DocAuthHelper
  include RecoveryHelper

  let(:user) { create(:user, :with_phone) }
  let(:good_ssn) { '666-66-1234' }
  let(:profile) { build(:profile, :active, :verified, user: user, pii: { ssn: good_ssn }) }
  let(:bad_pii) do
    IdentityDocAuth::Mock::ResultResponseBuilder::DEFAULT_PII_FROM_DOC.merge(ssn: '123')
  end

  before do
    sign_in_before_2fa(user)
    allow_any_instance_of(Idv::Steps::RecoverVerifyWaitStepShow).to receive(:saved_pii).
      and_return(bad_pii.to_json)
    complete_recovery_steps_before_verify_step
    click_idv_continue
  end

  it 'fails to re-verify if the pii does not match and then it proceeds to start re-verify over' do
    expect(page).to have_current_path(idv_session_errors_recovery_warning_path)
  end
end
