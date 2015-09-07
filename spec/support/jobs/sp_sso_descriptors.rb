RSpec.shared_examples 'update from FR: sp_sso_descriptors' do
  let(:service_providers) do
    (1..sp_count).to_a.map do |i|
      {
        id: (2000 + i)
      }
    end
  end
end
