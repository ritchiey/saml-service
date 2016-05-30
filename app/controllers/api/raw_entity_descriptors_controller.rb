module API
  class RawEntityDescriptorsController < APIController
    before_action do
      @entity_source = EntitySource[source_tag: params[:tag]]
      fail(ResourceNotFound) if @entity_source.nil?
    end

    def create
      check_access!(access_path)
      fail(BadRequest) unless valid_post_params?
      render status: :ok, nothing: true
    end

    private

    def post_params
      params.require(:raw_entity_descriptor)
        .permit(:xml, :entity_id, :created_at, :updated_at, :enabled)
    end

    def valid_post_params?
      required_keys = [:xml, :entity_id, :created_at, :updated_at, :enabled]
      required_keys.all? { |k| post_params.key? k }
    end

    def access_path
      "entity_sources:#{@entity_source.source_tag}:raw_entity_descriptors:"\
      'create'
    end
  end
end
