RSpec.shared_examples 'update from FR: attribute_authority_descriptors' do
  let(:attribute_authorities) do
    (1..idp_count).to_a.map do |i|
      {
        id: (3000 + i)
      }
    end
  end
end
