class GamesController < ApplicationController
  def index
    @games = Storage::Game.page(params[:page])
  end

  def show
    @game = Storage::Game.find(params[:id])
  end
end
