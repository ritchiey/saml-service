module DualOwners
  extend ActiveSupport::Concern

  def valid_owner(parents)
    owners = parents.map { |parent| send(parent) }.compact
    return if owners.one?

    errors.add(:ownership, "Must be owned by #{parents[0]}" \
                           " or #{parents[1]}") && return if owners.none?
    errors.add(:ownership, "Cannot be owned by both #{parents[0]}" \
                           " and #{parents[1]}")
  end
end
