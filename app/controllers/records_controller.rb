class RecordsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :set_record, only: [:show, :edit, :update, :destroy]

  # GET /records
  # GET /records.json
  def index
    # submissions
    # TODO: infinite scroll
    page = 1
    if params[:page] != nil
      page = params[:page]
    end

    @only_show_teamid = params[:teamid]

    if @only_show_teamid == nil
        @records =
          Record.all
          .order(created_at: :desc)
          .offset((page.to_i - 1) * MyConstants::MAX_ROWS)
          .limit(MyConstants::MAX_ROWS)
    else
        @records =
          Record.all
          .order(created_at: :desc)
    end

    # scoreboard
    @team_points = nil
    @team_suc_chals = nil
    @team_rank_by_points = nil
    rank_records
  end

  # GET /records/1
  # GET /records/1.json
  def show
  end

  # GET /records/new
  def new
    @record = Record.new
  end

  # GET /records/1/edit
  def edit
  end

  # POST /records
  # POST /records.json
  def create
      if params[:diy] != nil
        _record_params = record_params_json
      else
        _record_params = record_params
      end
    successful = check_answer(_record_params[:chalid], _record_params[:answer])

    @record = Record.new(_record_params)
    @record.successful = successful

    respond_to do |format|
      if @record.save
        if successful
          format.html { redirect_to records_url, notice: '正確!' }
          format.json { render json: @record }
#           format.json { render :show, status: :created, location: @record }
        else
          format.html { redirect_to records_url, notice: '不正確，再試試吧' }
          format.json { render json: @record }
#           format.json { render :show, status: :created, location: @record }
        end
      else
        format.html { render :new }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /records/1
  # PATCH/PUT /records/1.json
  def update
    respond_to do |format|
      if @record.update(record_params)
        format.html { redirect_to @record, notice: 'Record was successfully updated.' }
        format.json { render :show, status: :ok, location: @record }
      else
        format.html { render :edit }
        format.json { render json: @record.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /records/1
  # DELETE /records/1.json
  def destroy
    @record.destroy
    respond_to do |format|
      format.html { redirect_to records_url, notice: 'Record was successfully destroyed.' }
      format.json { head :no_content }
    end
  end


private
  def check_answer(chalid, answer)
    chalid = chalid.to_i
    chal = MyConstants::CHALLENGES[chalid]
    if chal == nil
      return false
    end

    return answer == chal[0]
  end

  def rank_records()
    # problems at which each team succeeds
    raw_suc_records = Record.select("teamid, chalid, diy")
                            .where(successful: true)
                            .order(:teamid, :chalid, diy: :asc)
    # remove duplicate records
    suc_records = []
    for rec in raw_suc_records
      if suc_records.empty? \
            or suc_records.last.teamid != rec.teamid \
            or suc_records.last.chalid != rec.chalid
        suc_records << rec

      elsif suc_records.last.diy.blank? and not rec.diy.blank?
        suc_records.pop
        suc_records << rec
      end

    end

    # suc_chals and points use teamid as key
    @team_suc_chals = {}
    @team_points = {}
    # store teamid, ranked by their total points
    @team_rank_by_points = []
    for i in (0..MyConstants::TOTAL_TEAMS)
      @team_suc_chals[i] = []
      @team_points[i] = 0
      @team_rank_by_points << i
    end

    for rec in suc_records
      # get challenge points
      chal = MyConstants::CHALLENGES[rec.chalid]
      if chal == nil
        next
      end
      points = chal[1]

      # calculate total points of a team
      if rec.diy.blank?
        @team_points[ rec.teamid ] += points
      else
        # bonus for using Python to make request
        @team_points[ rec.teamid ] += points * 2
      end

      @team_suc_chals[ rec.teamid ] << rec.chalid
    end

    # sort by team points
    @team_rank_by_points.sort_by! { |teamid| @team_points[teamid] }
    @team_rank_by_points.reverse!
    # sort succeeded challenges of each team, to make it look clear
    @team_suc_chals.values.each { |r| r.sort! }
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_record
    @record = Record.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def record_params_json
    params.permit(:teamid, :chalid, :name, :answer, :diy)
  end

  def record_params
    params.require(:record).permit(:teamid, :chalid, :name, :answer, :diy)
  end

end
