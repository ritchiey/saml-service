require 'digest/sha1'

class EntityId < SamlURI
  many_to_one :entity_descriptor

  def validate
    super
    validates_presence [:entity_descriptor, :sha1]
    validates_max_length 1024, :uri
  end

  def before_validation
    super
    self.sha1 = Digest::SHA1.hexdigest uri if uri
  end
end
