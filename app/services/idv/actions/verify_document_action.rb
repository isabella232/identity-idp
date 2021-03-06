module Idv
  module Actions
    class VerifyDocumentAction < Idv::Steps::DocAuthBaseStep
      def call
        enqueue_job
      end

      private

      def form_submit
        response = form.submit
        presenter = ImageUploadResponsePresenter.new(
          form: form,
          form_response: response,
        )
        status = :accepted if response.success?
        render_json(
          presenter,
          status: status || presenter.status,
        )
        response
      end

      def form
        @form ||= Idv::ApiDocumentVerificationForm.new(
          params,
          liveness_checking_enabled: liveness_checking_enabled?,
        )
      end

      def enqueue_job
        document_capture_session = create_document_capture_session(
          verify_document_capture_session_uuid_key,
        )
        document_capture_session.requested_at = Time.zone.now
        document_capture_session.store_proofing_pii_from_doc({})

        VendorDocumentVerificationJob.perform(
          document_capture_session_result_id: document_capture_session.result_id,
          encryption_key: params[:encryption_key],
          front_image_iv: params[:front_image_iv],
          back_image_iv: params[:back_image_iv],
          selfie_image_iv: params[:selfie_image_iv],
          front_image_url: params[:front_image_url],
          back_image_url: params[:back_image_url],
          selfie_image_url: params[:selfie_image_url],
          liveness_checking_enabled: params[:liveness_checking_enabled],
        )
      end
    end
  end
end
