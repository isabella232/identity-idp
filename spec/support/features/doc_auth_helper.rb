module DocAuthHelper
  def session_from_completed_flow_steps(finished_step)
    session = { doc_auth: {} }
    Idv::Flows::DocAuthFlow::STEPS.each do |step, klass|
      session[:doc_auth][klass.to_s] = true
      return session if step == finished_step
    end
    session
  end

  def fill_out_ssn_form_with_duplicate_ssn
    diff_user = create(:user)
    create(:profile, pii: { ssn: '123-45-6666' }, user: diff_user)
    fill_in 'doc_auth_ssn', with: '123-45-6666'
  end

  def fill_out_ssn_form_with_ssn_that_fails_resolution
    fill_in 'doc_auth_ssn', with: '123-45-6666'
  end

  def fill_out_ssn_form_with_ssn_that_raises_exception
    fill_in 'doc_auth_ssn', with: '000-00-0000'
  end

  def fill_out_ssn_form_ok
    fill_in 'doc_auth_ssn', with: '666-66-1234'
  end

  def fill_out_ssn_form_fail
    fill_in 'doc_auth_ssn', with: ''
  end

  def idv_doc_auth_welcome_step
    idv_doc_auth_step_path(step: :welcome)
  end

  def idv_doc_auth_upload_step
    idv_doc_auth_step_path(step: :upload)
  end

  def idv_doc_auth_ssn_step
    idv_doc_auth_step_path(step: :ssn)
  end

  def idv_doc_auth_document_capture_step
    idv_doc_auth_step_path(step: :document_capture)
  end

  def idv_doc_auth_front_image_step
    idv_doc_auth_step_path(step: :front_image)
  end

  def idv_doc_auth_mobile_front_image_step
    idv_doc_auth_step_path(step: :mobile_front_image)
  end

  def idv_doc_auth_back_image_step
    idv_doc_auth_step_path(step: :back_image)
  end

  def idv_doc_auth_mobile_back_image_step
    idv_doc_auth_step_path(step: :mobile_back_image)
  end

  def idv_doc_auth_verify_step
    idv_doc_auth_step_path(step: :verify)
  end

  def idv_doc_auth_selfie_step
    idv_doc_auth_step_path(step: :selfie)
  end

  def idv_doc_auth_send_link_step
    idv_doc_auth_step_path(step: :send_link)
  end

  def idv_doc_auth_link_sent_step
    idv_doc_auth_step_path(step: :link_sent)
  end

  def idv_doc_auth_email_sent_step
    idv_doc_auth_step_path(step: :email_sent)
  end

  def complete_doc_auth_steps_before_welcome_step(expect_accessible: false)
    visit idv_doc_auth_welcome_step unless current_path == idv_doc_auth_welcome_step
    expect(page).to be_accessible.according_to :section508, :"best-practice" if expect_accessible
  end

  def complete_doc_auth_steps_before_upload_step(expect_accessible: false)
    complete_doc_auth_steps_before_welcome_step(expect_accessible: expect_accessible)
    find('label', text: t('doc_auth.instructions.consent')).click
    click_on t('doc_auth.buttons.continue')
  end

  def complete_doc_auth_steps_before_document_capture_step(expect_accessible: false)
    complete_doc_auth_steps_before_upload_step(expect_accessible: expect_accessible)
    expect(page).to be_accessible.according_to :section508, :"best-practice" if expect_accessible
    click_on t('doc_auth.info.upload_computer_link')
  end

  def complete_doc_auth_steps_before_front_image_step(expect_accessible: false)
    complete_doc_auth_steps_before_upload_step(expect_accessible: expect_accessible)
    expect(page).to be_accessible.according_to :section508, :"best-practice" if expect_accessible
    click_on t('doc_auth.info.upload_computer_link')
  end

  def complete_doc_auth_steps_before_back_image_step(expect_accessible: false)
    complete_doc_auth_steps_before_front_image_step(expect_accessible: expect_accessible)
    expect(page).to be_accessible.according_to :section508, :"best-practice" if expect_accessible
    attach_image
    click_idv_continue
  end

  def complete_doc_auth_steps_before_email_sent_step
    allow(DeviceDetector).to receive(:new).and_return(mobile_device)
    complete_doc_auth_steps_before_upload_step
    click_on t('doc_auth.info.upload_computer_link')
  end

  def complete_doc_auth_steps_before_mobile_front_image_step
    complete_doc_auth_steps_before_upload_step
    allow(DeviceDetector).to receive(:new).and_return(mobile_device)
    click_on t('doc_auth.buttons.use_phone')
  end

  def complete_doc_auth_steps_before_mobile_back_image_step
    complete_doc_auth_steps_before_mobile_front_image_step
    attach_image
    click_idv_continue
  end

  def mobile_device
    DeviceDetector.new('Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) \
AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1')
  end

  def complete_doc_auth_steps_before_ssn_step(expect_accessible: false)
    complete_doc_auth_steps_before_document_capture_step(expect_accessible: expect_accessible)
    expect(page).to be_accessible.according_to :section508, :"best-practice" if expect_accessible
    if javascript_enabled?
      attach_images_with_javascript
    else
      attach_images(liveness_enabled: false)
      click_idv_continue
    end
  end

  def complete_doc_auth_steps_before_verify_step(expect_accessible: false)
    complete_doc_auth_steps_before_ssn_step(expect_accessible: expect_accessible)
    expect(page).to be_accessible.according_to :section508, :"best-practice" if expect_accessible
    if page.current_path == idv_doc_auth_document_capture_step
      attach_images(liveness_enabled: true)
      click_idv_continue
      expect(page).to be_accessible.according_to :section508, :"best-practice" if expect_accessible
    end
    fill_out_ssn_form_ok
    click_idv_continue
  end

  def complete_doc_auth_steps_before_address_step(expect_accessible: false)
    complete_doc_auth_steps_before_verify_step
    expect(page).to be_accessible.according_to :section508, :"best-practice" if expect_accessible
    click_link t('doc_auth.buttons.change_address')
  end

  def complete_doc_auth_steps_before_self_image_step
    complete_doc_auth_steps_before_verify_step
    click_idv_continue
  end

  def complete_doc_auth_steps_before_send_link_step
    complete_doc_auth_steps_before_upload_step
    click_on t('doc_auth.buttons.use_phone')
  end

  def complete_doc_auth_steps_before_link_sent_step
    complete_doc_auth_steps_before_send_link_step
    fill_out_doc_auth_phone_form_ok
    click_idv_continue
  end

  def complete_all_doc_auth_steps(expect_accessible: false)
    complete_doc_auth_steps_before_verify_step(expect_accessible: expect_accessible)
    expect(page).to be_accessible.according_to :section508, :"best-practice" if expect_accessible
    click_idv_continue
  end

  def mock_doc_auth_no_name_pii(method)
    pii_with_no_name = IdentityDocAuth::Mock::ResultResponseBuilder::DEFAULT_PII_FROM_DOC.dup
    pii_with_no_name[:last_name] = nil
    IdentityDocAuth::Mock::DocAuthMockClient.mock_response!(
      method: method,
      response: IdentityDocAuth::Response.new(
        pii_from_doc: pii_with_no_name,
        extra: {
          result: 'Passed',
          billed: true,
        },
        success: true,
        errors: {},
      ),
    )
  end

  def mock_general_doc_auth_client_error(method)
    IdentityDocAuth::Mock::DocAuthMockClient.mock_response!(
      method: method,
      response: IdentityDocAuth::Response.new(
        success: false,
        errors: { error: I18n.t('errors.doc_auth.general_error') },
      ),
    )
  end

  def mock_doc_auth_acuant_error_unknown
    failed_http_response = instance_double(
      Faraday::Response,
      body: AcuantFixtures.get_results_response_failure,
    )
    IdentityDocAuth::Mock::DocAuthMockClient.mock_response!(
      method: :get_results,
      response: IdentityDocAuth::Acuant::Responses::GetResultsResponse.new(
        failed_http_response,
        IdentityDocAuth::Acuant::Config.new,
      ),
    )
  end

  def mock_document_capture_result(idv_result)
    id = SecureRandom.uuid
    pii = { 'first_name' => 'Testy', 'last_name' => 'Testerson' }

    result = ProofingDocumentCaptureSessionResult.new(id: id, pii: pii, result: idv_result)
    allow_any_instance_of(DocumentCaptureSession).to receive(:load_proofing_result).
      and_return(result)
  end

  def attach_images(liveness_enabled: true)
    if Capybara.current_driver == Capybara.javascript_driver
      attach_file 'Front of your ID', 'app/assets/images/logo.png'
      attach_file 'Back of your ID', 'app/assets/images/logo.png'
      raise ArgumentError, 'liveness not currently supported in JS tests' if liveness_enabled
    else
      attach_file 'doc_auth_front_image', 'app/assets/images/logo.png'
      attach_file 'doc_auth_back_image', 'app/assets/images/logo.png'
      attach_file 'doc_auth_selfie_image', 'app/assets/images/logo.png' if liveness_enabled
    end
  end

  def attach_images_with_javascript
    attach_file 'Front of your ID', File.expand_path('spec/fixtures/ial2_test_credential.yml')
    attach_file 'Back of your ID', File.expand_path('spec/fixtures/ial2_test_credential.yml')
    click_on 'Submit'
  end

  def attach_front_image_data_url
    page.find('#doc_auth_front_image_data_url', visible: false).set(doc_auth_front_image_data_url)
  end

  def doc_auth_front_image_data_url
    File.read('spec/support/fixtures/doc_auth_front_image_data_url.data')
  end

  def doc_auth_front_image_multipart_file
    Rack::Test::UploadedFile.new('spec/support/fixtures/doc_auth_front_image.jpeg', 'image/jpeg')
  end

  def doc_auth_front_image_data_url_data
    Base64.decode64(doc_auth_front_image_data_url.split(',').last)
  end

  def attach_back_image_data_url
    page.find('#doc_auth_back_image_data_url', visible: false).set(doc_auth_back_image_data_url)
  end

  def doc_auth_back_image_data_url
    File.read('spec/support/fixtures/doc_auth_back_image_data_url.data')
  end

  def doc_auth_back_image_multipart_file
    Rack::Test::UploadedFile.new('spec/support/fixtures/doc_auth_back_image.jpeg', 'image/jpeg')
  end

  def doc_auth_back_image_data_url_data
    Base64.decode64(doc_auth_back_image_data_url.split(',').last)
  end

  def attach_selfie_image_data_url
    page.find('#doc_auth_selfie_image_data_url', visible: false).set(doc_auth_selfie_image_data_url)
  end

  def doc_auth_selfie_image_data_url
    File.read('spec/support/fixtures/doc_auth_selfie_image_data_url.data')
  end

  def doc_auth_selfie_image_multipart_file
    Rack::Test::UploadedFile.new('spec/support/fixtures/doc_auth_selfie_image.jpeg', 'image/jpeg')
  end

  def doc_auth_selfie_image_data_url_data
    Base64.decode64(doc_auth_selfie_image_data_url.split(',').last)
  end

  def attach_image
    attach_file 'doc_auth_image', 'app/assets/images/logo.png'
  end

  def attach_image_data_url
    page.find('#doc_auth_image_data_url', visible: false).set(doc_auth_image_data_url)
  end

  def doc_auth_image_data_url
    File.read('spec/support/fixtures/doc_auth_image_data_url.data')
  end

  def doc_auth_image_data_url_data
    Base64.decode64(doc_auth_image_data_url.split(',').last)
  end

  def fill_out_address_form_ok
    fill_in 'idv_form_address1', with: '123 Main St'
    fill_in 'idv_form_city', with: 'Nowhere'
    select 'Virginia', from: 'idv_form_state'
    fill_in 'idv_form_zipcode', with: '66044'
  end

  def fill_out_address_form_resolution_fail
    fill_in 'idv_form_address1', with: '123 Main St'
    fill_in 'idv_form_city', with: 'Nowhere'
    select 'Virginia', from: 'idv_form_state'
    fill_in 'idv_form_zipcode', with: '00000'
  end

  def fill_out_address_form_fail
    fill_in 'idv_form_address1', with: '123 Main St'
    fill_in 'idv_form_city', with: 'Nowhere'
    select 'Virginia', from: 'idv_form_state'
    fill_in 'idv_form_zipcode', with: '1'
  end

  def fill_out_doc_auth_phone_form_ok(phone = '415-555-0199')
    fill_in :doc_auth_phone, with: phone
  end
end
