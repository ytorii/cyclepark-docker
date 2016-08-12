require 'rails_helper'

RSpec.describe MultiSealsUpdateController, type: :controller do

  let(:admin){ create(:admin) }
  let(:normal){ create(:normal) }
  # As FactoryGirl sequence sets incremental numbers across the test case,
  # numbers needs to be set to fixed value! 
  let(:leaf_fn1){ 1.upto(3){|i| create(:count_first_normal_1, number: i)} }
  let(:leaf_fn2){ create(:count_first_normal_2, number: 4) }

  before{
    admin
    normal
    leaf_fn1
    leaf_fn2
  }

  shared_examples "gets page and list correctly" do |expected_list|
    it "returns http success" do
      expect(response).to have_http_status(:success)
    end

    it "returns seals_list as @unsealed_list." do
      assinged_lists = assigns(:unsealed_list).sealsid_list

      assinged_lists.each_with_index do |list, i|
        expect([ list.number, list.seal_id ]).
          to eq([ expected_list[i][0], expected_list[i][1] ])
      end
    end
  end

  shared_examples "gets multi seals list" do |session|

    let(:index_valid_params){
      { q: { vhiecle_type_eq: 1,
          contracts_seals_month_eq: "2016-06",
          valid_flag_eq: true,
          contracts_seals_sealed_flag_eq: false }
      }
    }

    let(:index_invalid_params){
      { q: { vhiecle_type_eq: 1,
          contracts_seals_month_eq: "あ",
          valid_flag_eq: true,
          contracts_seals_sealed_flag_eq: false }
      }
    }

    context "with no params" do
      before{ get :index, {}, session }

      it_behaves_like "gets page and list correctly",
        [ [1, 3], [2, 6], [3, 9], [4, 10] ]
    end

    context "with valid params" do
      before{ post :index, index_valid_params, session }
      it_behaves_like "gets page and list correctly",
        [ [1, 2], [2, 5], [3, 8] ]
    end

    context "with invalid param" do
      before{ post :index, index_invalid_params, session }
      it "returns http success" do
        expect(response).to have_http_status(:success)
      end

      it "returns flash alert message." do
        expect(flash[:alert]).to be_present
      end
    end
  end

  shared_examples "updates multi seals" do |session|

    let(:update_valid_params){
      { update_multi_seals: {
        staff_nickname: session[:nickname],
        sealed_date: "2016-06-03",
        sealsid_list: [ 3, 6, "" ] }
      }
    }

    let(:update_invalid_params){
      { update_multi_seals: {
        staff_nickname: session[:nickname],
        sealed_date: 'あ',
        sealsid_list: [ 3, 6, "" ] }
      }
    }

    context "with valid params" do
      before{ post :update, update_valid_params, session }
      it "update Seals with selected ids."do
        # Pop blank id in the last of list(this is added by rails' tag)
        update_valid_params[:update_multi_seals][:sealsid_list].pop

        update_valid_params[:update_multi_seals][:sealsid_list].each do |id|
          seal = Seal.find(id)
          expect(seal.sealed_flag).to eq(true)
          expect(seal.staff_nickname).to eq(session[:nickname])
          expect(seal.sealed_date).to eq( Date.parse("2016-06-03") )
        end
      end

      it "unchange Seals with unselected ids."do
        unselected_ids =
          Seal.all.pluck(:id) -
            update_valid_params[:update_multi_seals][:sealsid_list]

        unselected_ids.each do |id|
          seal = Seal.find(id)
          expect(seal.sealed_flag).to eq(false)
          expect(seal.staff_nickname).to eq(nil)
          expect(seal.sealed_date).to eq(nil)
        end
      end
    end

    context "with invalid param" do
      before{ post :update, update_invalid_params, session }
      it "returns http redirect." do
        expect(response).to have_http_status(:redirect)
      end

      it "returns flash alert message." do
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "GET #index" do
    context "with admin staff" do
      it_behaves_like "gets multi seals list",
        { staff: '1', nickname: 'admin' }
    end

    context "with normal staff" do
      it_behaves_like "gets multi seals list",
        { staff: '2', nickname: 'normal' }
    end
  end

  describe "GET #update" do
    context "with admin staff" do
      it_behaves_like "updates multi seals",
        { staff: '1', nickname: 'admin' }
    end
  end
end
