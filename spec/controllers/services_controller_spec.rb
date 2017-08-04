require 'rails_helper'

RSpec.describe ServicesController, type: :controller do

  describe 'check index' do
    it 'gives access when user is admin' do
      user = create(:user)
      get :index, session: { user_id: user.id }
      expect(response).to be_success
    end
    it 'redirects when user is not admin' do
      get :index
      expect(response).not_to be_success
    end
    it 'assigns all values as standard' do
      user = create(:user)
      get :index, session: { user_id: user.id }
      expect(assigns(:worker)).to eq('')
      expect(assigns(:data)).to eq('')
      expect(assigns(:result)).to eq('')
      expect(assigns(:web)).to eq('')
      expect(assigns(:max_raw_repo)).to eq("0")
      expect(assigns(:max_repo)).to eq("0")
      expect(assigns(:stop)).to eq("-1")
    end
    it 'loads all saved values' do
      user = create(:user)
      data = create :system_setting_data_path
      get :index, session: { user_id: user.id }
      expect(assigns(:worker)).to eq('')
      expect(assigns(:data)).to eq(data.value)
    end

    describe 'check stop' do
      it 'redirects when user is not admin' do
        post :stop
        expect(response).not_to be_success
      end
      it 'returns error if paths are empty' do
        user = create(:user)
        get :index, session: { user_id: user.id }
        post :stop
        expect(flash[:error]).to eq("Please fill in all Paths before starting the service.")
      end
      it 'changes values when triggered and path not empty (one way)' do
        create :system_setting_data_path
        create :system_setting_result_path
        create :system_setting_web_path
        create :system_setting_worker_path
        user = create(:user)
        get :index, session: { user_id: user.id }
        expect(assigns(:stop)).to eq("-1")
        post :stop, session: { user_id: user.id }
        get :index, session: { user_id: user.id }
        expect(assigns(:stop)).to eq("1")
      end

      it 'changes values when triggered and path not empty (other way)' do
        create :system_setting_data_path
        create :system_setting_result_path
        create :system_setting_web_path
        create :system_setting_worker_path
        user = create(:user)
        SystemSetting.create(name: 'Stop',value:1)
        get :index, session: { user_id: user.id }
        expect(assigns(:stop)).to eq("1")
        post :stop, session: { user_id: user.id }
        get :index, session: { user_id: user.id }
        expect(assigns(:stop)).to eq("-1")
      end

      describe 'check reset' do
        it 'redirects when user is not admin' do
          post :reset
          expect(response).not_to be_success
        end
        it 'shows error, when servie is running' do
          user = create(:user)
          SystemSetting.create(name: 'Stop',value:1)
          post :reset,  session: { user_id: user.id }
          expect(flash[:error]).to eq('Please stop the service first')
        end
        it 'deletes all raw_repos' do
          user = create(:user)
          create :system_setting_data_path
          create :system_setting_result_path
          create :system_setting_actual_size_repo
          create :system_setting_actual_size
          SystemSetting.create(name: 'Stop',value:-1)
          RawRepo.create(name:'abc',size:100,state:0)
          expect(RawRepo.count).to eq(1)
          post :reset, session: { user_id: user.id }
          expect(RawRepo.count).to eq(0)
        end
        it 'resets actual_size values' do
          user = create(:user)
          create :system_setting_data_path
          create :system_setting_result_path
          create :system_setting_actual_size_repo
          create :system_setting_actual_size
          SystemSetting.create(name: 'Stop',value:-1)
          post :reset, session: { user_id: user.id }
          expect(SystemSetting.find_by(name: 'Actual_Size_Repo').value).to eq("0")
          expect(SystemSetting.find_by(name: 'Actual_Size_Raw_Repo').value).to eq("0")
        end
        it 'deletes folder' do
          user = create(:user)
          data = create :system_setting_data_path
          result = create :system_setting_result_path
          create :system_setting_actual_size_repo
          create :system_setting_actual_size
          SystemSetting.create(name: 'Stop',value:-1)
          post :reset, session: { user_id: user.id }
          expect(Dir.exists?(data.value)).to be false
          expect(Dir.exists?(result.value)).to be false
        end

        describe 'checks manage' do
          it 'redirects when user is not admin' do
            params = {'serviceData'=>{'web'=>'web',
                                      'data'=>'data',
                                      'result'=>'result',
                                      'worker'=>'worker',
                                      'maxRawRepo'=>'200',
                                      'maxRepo'=>'100'},
                      'commit'=>'Save ServiceData'}
            post :manage, params: params
            expect(response).not_to be_success
          end
          it 'changes values' do
            user = create(:user)
            get :index, session: { user_id: user.id }
            params = {'serviceData'=>{'web'=>'web',
                                   'data'=>'data',
                                   'result'=>'result',
                                   'worker'=>'worker',
                                   'maxRawRepo'=>'200',
                                   'maxRepo'=>'100'},
                      'commit'=>'Save ServiceData'}
            post :manage, params: params, session: { user_id: user.id }
            get :index, session: { user_id: user.id }
            expect(assigns(:worker)).to eq('worker')
            expect(assigns(:data)).to eq('data')
            expect(assigns(:result)).to eq('result')
            expect(assigns(:web)).to eq('web')
            expect(assigns(:max_raw_repo)).to eq("200")
            expect(assigns(:max_repo)).to eq("100")
          end
        end


      end
    end


  end

end
