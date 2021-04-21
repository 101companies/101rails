Wiki::Application.config.middleware.use OmniAuth::Builder do
  # Rails.env == 'production' ? provider_suffix = '' : provider_suffix = '_DEV'
  # provider :github, ENV['GITHUB_KEY' + provider_suffix], ENV['GITHUB_SECRET' + provider_suffix]
  provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
end

OmniAuth.config.allowed_request_methods = [:post, :get]
