class SessionsController < ApplicationController
  allow_unauthenticated_access

  def index
    @user_session_ids = current_user&.sessions&.pluck(:id)
    @sessions = SessionQuery.new(
      relation: sessions.joins(:location).distinct,
      params: filter_params
    ).call.includes(:attendees, :tags).order(:starts_at)
  end

  def show
    if user_signed_in?
      @session = sessions.friendly.find(params[:id])
    else
      @session = sessions.publics.friendly.find(params[:id])
    end
  end

  private

  def sessions
    current_conference&.sessions
  end

  def filter_params
    params.permit(:starts_at, :live, :past, :starting_soon).merge(show_private: user_signed_in?)
  end
end
