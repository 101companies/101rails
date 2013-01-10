Wiki::Application.config.middleware.use OmniAuth::Builder do
  # OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  configure do |config|
    config.path_prefix = '/auth' if Rails.env == 'production'
  end


  Secrets::secret['omniauth'].each do |service, definition|
    provider service.to_sym, definition['key'], definition['secret']
  end
end