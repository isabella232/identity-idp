require 'rails_helper'

feature 'doc auth self image step' do
  include IdvStepHelper
  include DocAuthHelper
  include DocCaptureHelper

  before do
    allow_any_instance_of(DeviceDetector).to receive(:device_type).and_return('mobile')
    allow(Figaro.env).to receive(:liveness_checking_enabled).and_return('true')
    complete_doc_capture_steps_before_capture_complete_step
  end

  it 'is on the correct page' do
    expect(page).to have_current_path(idv_capture_doc_capture_selfie_step)
  end

  it 'proceeds to the next page with valid info' do
    attach_image
    click_idv_continue

    expect(page).to have_current_path(idv_capture_doc_capture_complete_step)
  end

  it 'restarts doc auth upon failure' do
    allow_any_instance_of(Acuant::Liveness).to receive(:call).and_return(nil)
    attach_image
    click_idv_continue

    expect(page).to have_current_path(idv_capture_doc_mobile_front_image_step(nil))
    expect(page).to have_content(t('errors.doc_auth.selfie'))
  end
end