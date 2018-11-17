class TwoFactorLoginOptionsForm
  include ActiveModel::Model

  attr_reader :selection
  attr_reader :configuration_id

  validates :selection, inclusion: { in: %w[voice sms auth_app piv_cac personal_key webauthn] }

  def initialize(user)
    self.user = user
  end

  def submit(params)
    selection = params[:selection]
    configuration_id = nil
    if selection =~ /(.+)[:_](\d+)/
      selection = Regexp.last_match(1)
      configuration_id = Regexp.last_match(2)
    end

    self.selection = selection
    self.configuration_id = configuration_id

    success = valid?

    FormResponse.new(success: success, errors: errors.messages, extra: extra_analytics_attributes)
  end

  private

  attr_accessor :user
  attr_writer :selection
  attr_writer :configuration_id

  def extra_analytics_attributes
    {
      selection: selection,
    }
  end
end
