class GamesController < ApplicationController
  def index
    @games = Storage::Game.order(id: :desc).page(params[:page])
  end

  def show
    @game = Storage::Game.find_by(external_id: params[:id])

    respond_to do |format|
      format.html
      format.json do
        render json: @game, include: :moves
      end
    end
  end
end
