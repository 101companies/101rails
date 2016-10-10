class Admin::UsersController < ApplicationController
  authorize_resource
  before_action :set_admin_user, only: [:show, :edit, :update, :destroy]
  layout :admin_layout

  # GET /admin/users
  # GET /admin/users.json
  def index
    @users = User.all
  end

  # GET /admin/users/1.json
  def show
  end

  # GET /admin/users/1/edit
  def edit
  end

  # POST /admin/users
  # POST /admin/users.json
  def create
    @user = User.new(admin_user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to admin_user_path(@user), notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: admin_user_path(@user) }
      else
        format.html { render :new }
        format.json { render json: @admin_user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/users/1
  # PATCH/PUT /admin/users/1.json
  def update
    respond_to do |format|
      if @user.update(admin_user_params)
        format.html { redirect_to edit_admin_user_path(@user), notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: admin_user_path(@user) }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def admin_layout
    'admin'
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_admin_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def admin_user_params
    params.require(:user).permit(:name, :email, :role)
  end
end
