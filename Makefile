deploy:
	cap deploy;
	cap assets:precompile;
	cap deploy:ln_assets;