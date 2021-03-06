require 'rails_helper'

RSpec.describe SealsController, type: :controller do

  let(:new_attributes) {
    {
      sealed_flag: true,
      sealed_date: "2016-02-28",
    }
  }

  let(:invalid_attributes) {
    {
      sealed_flag: 'true',
      sealed_date: "2016-02-28",
      staff_nickname: ""
    }
  }

  let(:valid_session) { {staff: '1', nickname: 'admin'} }
  let(:invalid_session) { {staff: '1'} }
  let(:first) {create(:first)}
  let(:first_contract) {build(:first_contract)}
  let(:seal){ Seal.where(sealed_flag: false).first }

  describe "PUT #update" do
    before{
      first_contract.leaf = first
      first_contract.save!
    }

    context "with valid params", :js => true do
      shared_examples 'update seal' do |nickname|
        before{
          xhr :put, :update, {
            :leaf_id => first.id,
            :id => seal.to_param,
            :contract_id => first_contract.id,
            :seal => new_attributes.merge(staff_nickname: nickname)
          }, valid_session
          seal.reload
        }

        it "returns http success." do
          expect(response.status).to eq(200)
        end

        it "updates the requested seal" do
          expect(seal.sealed_flag).to eq(true)
          expect(seal.sealed_date).to eq(Date.parse("2016-02-28"))
          expect(seal.staff_nickname).to eq("admin")
        end

        it "assigns the requested seal as @seal" do
          expect(assigns(:seal)).to eq(seal)
        end
      end

      context "with staff_nickname attribute" do
        it_behaves_like 'update seal', 'admin'
          
      end

      context "without staff_nickname attribute" do
        it_behaves_like 'update seal', nil
      end
    end

    context "with invalid params" do

      before {
        xhr :put, :update, {
          :leaf_id => first.id,
          :contract_id => first_contract.id,
          :id => seal.to_param,
          :seal => invalid_attributes
        }, invalid_session
      }

      it "returns http success." do
        expect(response.status).to eq(200)
      end

      it "assigns the seal as @seal" do
        expect(assigns(:seal)).to eq(seal)
      end
    end
  end
end
