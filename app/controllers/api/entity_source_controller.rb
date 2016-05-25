module API
  class EntitySourceController < APIController
    before_action do
      @entity_source = EntitySource[source_tag: params[:source_tag]]
      fail(ResourceNotFound) if @entity_source.nil?
    end

    def update
      check_access!("entity_source:#{@entity_source.source_tag}:update")
      render status: :ok, nothing: true
    end
  end
end
