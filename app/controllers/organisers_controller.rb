class OrganisersController < ApplicationController
  before_action :require_organiser

  def dashboard
    @mentees = MenteeApplication.where.not(email: current_user.email).no_evaluation
    @mentors = MentorApplication.wherenot(email: current_user.email).no_evaluation
  end

  def index
    display_organisers
    organisers_left
  end

  def create
    @user = User.new(email: params[:email], role:1)

    if @user.save
      OrganisersMailer.register(@user).deliver_now
      redirect_to organisers_path, notice: 'Instructions have been sent to the email'
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      display_organisers
      organisers_left
      render "index"
    end
  end

  def destroy
    User.find_by(role:1, id: params[:id]).delete
    redirect_to :back, notice: "Deleted successfully!"
  end

  private

  def display_organisers
    @organisers = User.where(role: 1, organiser_token:nil)
  end

  def organisers_left
    @pending_organisers = User.where(role: 1).where.not(organiser_token: nil)
  end
end
