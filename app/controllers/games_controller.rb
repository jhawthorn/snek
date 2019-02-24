class GamesController < ApplicationController
  def index
    @games = Storage::Game.order(id: :desc).page(params[:page])
  end

  def show
    @game = Storage::Game.find(params[:id])
  end
end
