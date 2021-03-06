require 'rails_helper'

RSpec.describe ContractsController, type: :controller do

  let(:valid_attributes) {
    attributes_for(:first_contract, leaf_id: 1).merge({
      seals_attributes: [{ sealed_flag: true }]
    })
  }

  let(:invalid_attributes) {
    attributes_for(:first_contract, leaf_id: 1, term1: '').merge({
      seals_attributes: [{ sealed_flag: true }]
    })
  }

  let(:new_attributes) {
    attributes_for(:first_contract_add, money1: 3000, contract_date: '2016-02-02', staff_nickname: 'normal').merge({
      seals_attributes: [{ id: contract.seals[0].id, sealed_flag: true, sealed_date: '2016-02-02', staff_nickname: 'normal' }]
    })
  }

  # session infomation for staffs
  let(:valid_session) { {staff: '1', nickname: 'admin'} }
  let(:normal_session) { {staff: '2', nickname: 'normal'} }

  # first cutomer
  let(:first) {create(:first)}
  # contracts for first customer
  let(:contract) { build(:first_contract) }
  let(:contract_add) { build(:first_contract_add) }

  before{ first }

  describe "GET #index" do
    it "assigns all contracts as @contracts" do
      contract = Contract.create! valid_attributes
      get :index, { :leaf_id => first.id }, valid_session
      expect(assigns(:contracts)).to eq([contract])
    end
  end

  describe "GET #show" do
    it "assigns the requested contract as @contract" do
      contract = Contract.create! valid_attributes
      get :show, {:id => contract.to_param, :leaf_id => first.id}, valid_session
      expect(assigns(:contract)).to eq(contract)
    end
  end

  describe "GET #edit" do
    it "assigns the requested contract as @contract" do
      contract = Contract.create! valid_attributes
      get :edit, {:id => contract.to_param, :leaf_id => first.id}, valid_session
      expect(assigns(:contract)).to eq(contract)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "returns http success." do
        xhr :post, :create, {:contract => valid_attributes, :leaf_id => first.id}, valid_session
        expect(response.status).to eq(200)
      end

      it "creates one new Contract." do
        expect {
          xhr :post, :create, {:contract => valid_attributes, :leaf_id => first.id}, valid_session
        }.to change(Contract, :count).by(1)
      end

      it "creates seven new Seals." do
        expect {
          xhr :post, :create, {:contract => valid_attributes, :leaf_id => first.id}, valid_session
        }.to change(Seal, :count).by(7)
      end

      it "updates leaf's last month to Seals' last month." do
        xhr :post, :create, {:contract => valid_attributes, :leaf_id => first.id}, valid_session
        expect(Leaf.find(first.id).last_date).to eq(Seal.all.last.month.end_of_month)
      end
    end

    context "with invalid params" do
      it "returns http success." do
        xhr :post, :create, {:contract => invalid_attributes, :leaf_id => first.id}, valid_session
        expect(response.status).to eq(200)
      end

      it "fails to create new Contract." do
        expect {
          xhr :post, :create, {:contract => invalid_attributes, :leaf_id => first.id}, valid_session
        }.to change(Contract, :count).by(0)
      end

      it "fails to create new Seals." do
        expect {
          xhr :post, :create, {:contract => invalid_attributes, :leaf_id => first.id}, valid_session
        }.to change(Seal, :count).by(0)
      end

      it "fails to update leaf's last month to Seals' last month." do
        last_date = first.last_date 
          xhr :post, :create, {:contract => invalid_attributes, :leaf_id => first.id}, valid_session
        first.reload
        expect(first.last_date).to eq(last_date)
      end

      it "assigns a newly created but unsaved contract as @contract" do
        xhr :post, :create, {:contract => invalid_attributes, :leaf_id => first.id}, valid_session
        expect(assigns(:contract)).to be_a_new(Contract)
      end
    end
  end

  describe "PUT #update" do
    let(:contract) { create(:first_contract_edit, leaf_id: first.id) }

    context "with valid params" do
      before{
        put :update, {:id => contract.to_param, :leaf_id => contract.leaf_id, :contract => new_attributes}, valid_session
        contract.reload
      }

      it "updates the requested contract" do
        expect(contract.money1).to eq(3000)
        expect(contract.contract_date).to eq(Date.parse("2016-02-02"))
        expect(contract.staff_nickname).to eq("normal")
      end

      it "updates sealed_flag and staf_nickname with true sealed_flag." do
        expect(contract.seals.first.sealed_flag).to eq(true)
        expect(contract.seals.first.sealed_date).to eq(Date.parse("2016-02-02"))
        expect(contract.seals.first.staff_nickname).to eq('normal')
      end

      it "assigns the requested contract as @contract" do
        expect(assigns(:contract)).to eq(contract)
      end

      it "redirects to the leaf's page." do
        expect(response).to redirect_to(leaf_path(contract.leaf_id))
      end
    end

    context "with changed terms" do
      before{
        put :update, {:id => contract.to_param, :leaf_id => contract.leaf_id, :contract => valid_attributes}, valid_session
        contract.reload
      }

      it "assigns the requested contract as @contract" do
        expect(assigns(:contract)).to eq(contract)
      end

      it "redirects to the leaf's page." do
        expect(response).to redirect_to(leaf_path(contract.leaf_id))
      end
    end
  end

  describe "DELETE #destroy" do
    let(:contract_add) { create(:first_contract_add, leaf_id: first.id) }
    let(:contract) { create(:first_contract, leaf_id: first.id) }

    before{
      contract_add
      contract
    }

    it "destroys the requested contract" do
      expect {
        delete :destroy, {:id => contract.to_param, :leaf_id => contract.leaf_id}, valid_session
      }.to change(Contract, :count).by(-1)
    end

    it "destroys seals related to the destroyed contract." do
      expect {
        delete :destroy, {:id => contract.to_param, :leaf_id => contract.leaf_id}, valid_session
      }.to change(Seal, :count).by(-7)
    end

    it "changes leaf's last_date to the last seal's month after deleted." do
        delete :destroy, {:id => contract.to_param, :leaf_id => contract.leaf_id}, valid_session
        first.reload
        expect(first.last_date).to eq(contract_add.seals.last.month.end_of_month)
    end

    it "rejects to destroy contract unless it is the last contract." do
      expect {
        delete :destroy, {:id => contract_add.to_param, :leaf_id => contract_add.leaf_id}, valid_session
      }.to change(Contract, :count).by(0)
    end

    it "redirects to the leaf's page." do
      delete :destroy, {:id => contract.to_param, :leaf_id => contract.leaf_id}, valid_session
      expect(response).to redirect_to(leaf_path(first.id))
    end
  end
end
