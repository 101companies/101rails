Wiki::Application.config.middleware.use OmniAuth::Builder do
  Rails.env == 'development' ? provider_suffix = '_DEV' : provider_suffix = ''
  provider :github, ENV['GITHUB_KEY' + provider_suffix], ENV['GITHUB_SECRET' + provider_suffix]
end
