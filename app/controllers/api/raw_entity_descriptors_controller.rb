module API
  class RawEntityDescriptorsController < APIController
    before_action do
      @entity_source = EntitySource[source_tag: params[:tag]]
      fail(ResourceNotFound) if @entity_source.nil?
    end

    def create
      check_access!(access_path)
      render status: :ok, nothing: true
    end

    private

    def access_path
      "entity_sources:#{@entity_source.source_tag}:raw_entity_descriptors:"\
      'create'
    end
  end
end
