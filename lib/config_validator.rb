class ConfigValidator
  ENV_PREFIX = ""

  def validate(env = ENV)
    validate_boolean_keys(env)
  end

  private

  def boolean_warning(bad_keys)
    "You have invalid values (yes/no) for #{bad_keys.uniq.to_sentence} " \
    "in config/application.yml or your environment. " \
    "Please change them to true or false."
  end

  def candidate_keys(env)
    @candidate_keys ||= env.keys.keep_if { |key| candidate_key?(env, key) }
  end

  def candidate_key?(env, key)
    # A key is associated with a configuration setting if there are two
    # settings in the environment: one with and without the Figaro prefix.
    # We're only interested in the configuration settings and not other
    # environment variables.

    env.include?(key) and env.include?(ENV_PREFIX + key)
  end

  def keys_with_bad_boolean_values(env, keys)
    # Configuration settings for boolean values need to be "true/false"
    # and not "yes/no".

    keys.keep_if { |key| %w[yes no].include?(env[key].strip.downcase) }
  end

  def validate_boolean_keys(env)
    bad_keys = keys_with_bad_boolean_values(env, candidate_keys(env))
    return unless bad_keys.any?
    raise boolean_warning(bad_keys).tr("\n", ' ')
  end
end
