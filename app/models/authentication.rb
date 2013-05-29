# Store omni-auth Authentications in an extra collection.
# This is rational-related to the User-model to prevent us to iterate through
# all user when we receive a callback-request from the provider.
class Authentication
  include Mongoid::Document
  include Mongoid::Timestamps

  field :provider
  field :uid

  belongs_to :user

  # Some providers can not be displayed as a humanized version of their
  # symbol. provide_name will do the translation.
  def provider_name
    case provider
    when 'open_id'
      "OpenID"
    else
      provider.titleize
    end
  end

end
