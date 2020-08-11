class LinksController < ApplicationController
  def index
    render json: current_user.links.map { |link| { target: link.target, slug: link.slug } }
  end
end
