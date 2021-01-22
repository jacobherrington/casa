class CaseContacts::FollowupsController < ApplicationController
  after_action :verify_authorized

  def create
    authorize Followup
    case_contact = CaseContact.find(params[:case_contact_id])

    case_contact.followups.create(creator: current_user, status: :requested)

    redirect_to casa_case_path(case_contact.casa_case)
  end

  def resolve
    @followup = Followup.find(params[:id])
    authorize @followup

    @followup.resolved!
    create_notification

    redirect_to casa_case_path(@followup.case_contact.casa_case)
  end

  private

  def create_notification
    return if current_user == @followup.creator
    FollowupResolvedNotification
      .with(followup: @followup)
      .deliver(@followup.creator)
  end
end
