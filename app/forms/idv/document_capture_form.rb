module Idv
  class DocumentCaptureForm
    include ActiveModel::Model

    ATTRIBUTES = %i[front_image front_image_data_url
                    back_image back_image_data_url
                    selfie_image selfie_image_data_url].freeze

    attr_accessor :front_image, :front_image_data_url,
                  :back_image, :back_image_data_url,
                  :selfie_image, :selfie_image_data_url

    attr_reader :liveness_checking_enabled

    validate :front_image_or_image_data_url_presence
    validate :back_image_or_image_data_url_presence
    validate :selfie_image_or_image_data_url_presence

    def initialize(**args)
      @liveness_checking_enabled = args.delete(:liveness_checking_enabled)
      super
    end

    def self.model_name
      ActiveModel::Name.new(self, nil, 'Image')
    end

    def submit(params)
      consume_params(params)

      FormResponse.new(success: valid?, errors: errors.messages, extra: extra_analytics_attributes)
    end

    private

    def extra_analytics_attributes
      is_fallback_link = front_image.present? || back_image.present? || selfie_image.present?
      { is_fallback_link: is_fallback_link }
    end

    def front_image_or_image_data_url_presence
      return if front_image.present? || front_image_data_url.present?
      errors.add(:front_image, :blank)
    end

    def back_image_or_image_data_url_presence
      return if back_image.present? || back_image_data_url.present?
      errors.add(:back_image, :blank)
    end

    def selfie_image_or_image_data_url_presence
      return unless liveness_checking_enabled
      return if selfie_image.present? || selfie_image_data_url.present?
      errors.add(:selfie_image, :blank)
    end

    def consume_params(params)
      params.each do |key, value|
        raise_invalid_image_parameter_error(key) unless ATTRIBUTES.include?(key.to_sym)
        send("#{key}=", value)
      end
    end

    def raise_invalid_image_parameter_error(key)
      raise ArgumentError, "#{key} is an invalid image attribute"
    end
  end
end
