class Ahoy::Store < Ahoy::DatabaseStore
  def authenticate(data)
  end
end

Ahoy.exclude_method = lambda do |controller, request|
  controller.current_user.nil?
end

Ahoy.mask_ips = true
Ahoy.cookies = false
Ahoy.geocode = false
