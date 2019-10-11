require 'rails_helper'

RSpec.describe User, type: :model do
  context 'Associations' do
    it 'has_many pto_requests' do
      association = described_class.reflect_on_association(:pto_requests).macro

      expect(association).to eq :has_many
    end
	end
end
