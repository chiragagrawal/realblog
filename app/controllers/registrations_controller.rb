class RegistrationsController < Devise::RegistrationsController
  def update
    # For Rails 4
    # account_update_params = devise_parameter_sanitizer.sanitize(:account_update)
    # For Rails 3
     account_update_params = params[:user]

    # required for settings form to submit when password is left blank
    if account_update_params[:password].blank?
      account_update_params.delete("password")
      account_update_params.delete("password_confirmation")
    end

    @user = User.find(current_user.id)
    if @user.update_attributes(account_update_params)
      if @user.photos.blank?
        Photo.create(:data => params[:file].read,:filename => params[:file].original_filename,:mime_type=>params[:file].content_type,:photable_type=>'User',:photable_id=>@user.id) if !params[:file].blank?
      else
        @user.photos.first.update_attributes(:data => params[:file].read,:filename => params[:file].original_filename,:mime_type=>params[:file].content_type,:photable_type=>'User',:photable_id=>@user.id) if !params[:file].blank?
      end 
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case their password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end
end