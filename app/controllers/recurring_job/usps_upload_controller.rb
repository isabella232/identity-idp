module RecurringJob
  class UspsUploadController < AuthTokenController
    def create
      today = Time.zone.today
      UspsConfirmationUploader.new.run unless HolidayService.observed_holiday?(today)
      render plain: 'ok'
    end

    private

    def config_auth_token
      AppConfig.env.usps_upload_token
    end
  end
end
