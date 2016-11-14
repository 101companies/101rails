MessageBus.user_id_lookup do |env|
  req = Rack::Request.new(env)
  if req.session && req.session["user_id"]
    user = User.find(req.session['user_id'])
    user.id
  end
end


MessageBus.configure(backend: :redis, url: "redis://127.0.0.1:6379/15")
