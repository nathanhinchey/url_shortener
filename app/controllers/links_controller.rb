class LinksController < ApplicationController
  before_action :authenticate_user, except: :slug_redirect

  def index
    render json: current_user.links.map { |link| { target: link.target, slug: link.slug } }
  end

  def create
    link = Link.create(user: current_user, target: params[:target], slug: params[:slug])
    if link.valid?
      render json: { target: link.target, slug: link.slug }, status: :created
    else
      render json: { errors: link.errors.messages }, status: :unprocessable_entity
    end
  end

  def slug_redirect
    link = Link.find_by(slug: params[:slug])
    if link
      redirect_to link.target
    else
      render html: "We don't have a redirect for that. Sorry.", status: :not_found
    end
  end

  def destroy
    link = Link.find_by(slug: params[:id])
    if !link
      render json: {error: 'not found'}, status: 404
    elsif link.user == current_user
      link.destroy
    else
      render json: { error: 'slug belongs to another user' }, status: :forbidden
    end
  end
end
