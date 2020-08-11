class LinksController < ApplicationController
  before_action :authenticate_user, except: :slug_redirect

  def index
    render json: current_user.links.map { |link| { target: link.target, slug: link.slug } }
  end

  def create
    if Link.find_by(slug: params[:slug])
      render json: { error: 'slug unavailable' }, status: 422
    else
      link = Link.create!(user: current_user, target: params[:target], slug: params[:slug])
      render json: { target: link.target, slug: link.slug }, status: :created
    end
  end

  def slug_redirect
    link = Link.find_by(slug: params[:slug])
    if link
      redirect_to link.target
    else
      render html: '404: Not Found.', status: :not_found
    end
  end
end
