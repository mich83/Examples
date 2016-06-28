class Admin::TimeZoneChangesController < Admin::ApplicationController
  load_and_authorize_resource

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: TimeZoneChangesDatatable.new(view_context, TimeZoneChange.includes(:base_agency)) }
    end
  end

  def show

  end

  def edit

  end

  def new

  end

  def create
    @time_zone_change = TimeZoneChange.new(params[:time_zone_change])
    if @time_zone_change.save
      redirect_to  [:admin , @time_zone_change], notice: t('notices.success.male.create', model: TimeZoneChange.model_name.human)
    else
      render action: "new", alert: t('notices.failed.male.create', model: TimeZoneChange.model_name.human)
    end
  end

  def update
    if @time_zone_change.update_attributes(params[:time_zone_change])
      redirect_to  [:admin , @time_zone_change], notice: t('notices.success.male.update', model: TimeZoneChange.model_name.human)
    else
      render action: "edit", alert: t('notices.failed.male.update', model: TimeZoneChange.model_name.human)
    end
  end

  def destroy
    @time_zone_change.destroy
    redirect_to admin_time_zone_changes_path
  end
end