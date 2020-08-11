class LinksController < ApplicationController
  def index
    render json: current_user.links.map { |link| { target: link.target, slug: link.slug } }
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
