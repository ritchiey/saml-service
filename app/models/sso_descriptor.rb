class SSODescriptor < RoleDescriptor
  one_to_many :artifact_resolution_services
  one_to_many :single_logout_services
  one_to_many :manage_name_id_services
  one_to_many :name_id_formats

  def validate
    super
  end

  def artifact_resolution_services?
    artifact_resolution_services.present?
  end

  def single_logout_services?
    single_logout_services.present?
  end

  def manage_name_id_services?
    manage_name_id_services.present?
  end

  def name_id_formats?
    name_id_formats.present?
  end
end
