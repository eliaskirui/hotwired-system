class ApplicantsController < ApplicationController
  include Filterable
  before_action :turbo_frame_request_variant
  before_action :set_applicant, only: %i[ show edit update destroy change_stage ]
  before_action :authenticate_user!

  def change_stage
    @applicant.update(applicant_params)
    head :ok
  end

  # GET /applicants or /applicants.json
  # def index
  #   @applicants = Applicant.all
  # end
  def index

    @grouped_applicants = filter!(Applicant)
                            .for_account(current_user.account_id)
                            .group_by(&:stage)

    if search_params.present?
      @applicants = Applicant.includes(:job)
      @applicants = @applicants.where(job_id: search_params[:job]) if search_params[:job].present?
      @applicants = @applicants.text_search(search_params[:query]) if search_params[:query].present?
      if search_params[:sort].present?
        sort = search_params[:sort].split('-')
        @applicants = @applicants.order("#{sort[0]} #{sort[1]}")
      end
    else
      @applicants = Applicant.includes(:job).all
    end
  end

  # GET /applicants/1 or /applicants/1.json
  def show
  end

  # GET /applicants/new
  def new
    html = render_to_string(partial: 'form', locals: { applicant: Applicant.new })
    render operations: cable_car
                         .inner_html('#slideover-content', html: html)
                         .text_content('#slideover-header', text: 'Add an applicant')
  end
  # GET /applicants/1/edit
  def edit
  end

  # POST /applicants or /applicants.json
  def create
    @applicant = Applicant.new(applicant_params)
    if @applicant.save
      html = render_to_string(partial: 'card', locals: { applicant: @applicant })
      render operations: cable_car
                           .prepend("#applicants-#{@applicant.stage}", html: html)
                           .dispatch_event(name: 'submit:success')
    else
      html = render_to_string(partial: 'form', locals: { applicant: @applicant })
      render operations: cable_car
                           .inner_html('#applicant-form', html: html), status: :unprocessable_entity
    end
  end

  # PATCH/PUT /applicants/1 or /applicants/1.json
  def update
    respond_to do |format|
      if @applicant.update(applicant_params)
        format.html { redirect_to applicant_url(@applicant), notice: "Applicant was successfully updated." }
        format.json { render :show, status: :ok, location: @applicant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @applicant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /applicants/1 or /applicants/1.json
  def destroy
    @applicant.destroy

    respond_to do |format|
      format.html { redirect_to applicants_url, notice: "Applicant was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_applicant
      @applicant = Applicant.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def applicant_params
      params.require(:applicant).permit(:first_name, :last_name, :email, :phone, :stage, :status, :job_id, :resume)
    end

  def search_params
    params.permit(:query, :job, :sort)
  end

  def turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end
end
