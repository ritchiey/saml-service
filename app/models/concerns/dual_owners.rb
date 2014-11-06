module DualOwners
  extend ActiveSupport::Concern

  def valid_owner(owners)
    return if owners.one?

    if owners.none?
      errors.add(:ownership, "must be owned by #{owners[0]} or #{owners[1]}")
    else
      errors.add(:ownership, "cannot be owned by #{owners[0]} and #{owners[1]}")
    end
  end
end
