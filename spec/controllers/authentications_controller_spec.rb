require 'rails_helper'

RSpec.describe AuthenticationsController, type: :controller do

  describe 'create' do

    it 'has missing user' do
      request.env["omniauth.auth"] = {
        'info' => {
          'email': 'test@test.com'
        }
      }

      post(:create)

      expect(response).to redirect_to(page_path('101project'))
      expect(flash[:error]).to include('Failed to login')
    end

    it 'can login by email' do
      user = create(:user)

      request.env["omniauth.auth"] = {
        'info' => {
          'email'     => user.email,
          'name'      => user.name,
          'nickname'  => user.github_name,
          'image'     => user.github_avatar,
        },
        'credentials' => {
          'token'     => user.github_token
        },
        'uid'       => user.github_uid
      }

      post(:create)

      expect(session[:user_id]).to eq(user.id)
    end

  end

  describe 'local auth' do

    it 'does not work in production' do
      allow(Rails.env).to receive(:production?).and_return(true)

      post(:local_auth, params: { admin: 1 })

      expect(response).to redirect_to(page_path('101project'))
    end

    it 'works' do
      user = create(:user)

      post(:local_auth, params: { admin: user.id })

      expect(session[:user_id]).to eq(user.id)
    end

  end

  describe 'logout' do
    it 'logs out' do
      session[:user_id] = 1

      get(:destroy)

      expect(session[:user_id]).to be(nil)
      expect(response).to redirect_to(page_path('101project'))
    end
  end

end
