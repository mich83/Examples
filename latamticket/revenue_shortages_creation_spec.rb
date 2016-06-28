require 'spec_helper'

describe 'Creation of revenue with shortages', type: :request do
  let!(:role) { create(:role, :pos, name: "create_pos_api/revenues_controller") }
  let!(:pos_user) { create(:pos_user, role_ids: [role.id]) }
  let!(:pos) { create(:pos, active_user: pos_user, is_used: true) }
  let!(:cash_register) { create(:cr, :opened, point_of_sale: pos, user_enterprise: pos_user) }

  let!(:bus) { create(:bus) }
  let!(:responsible) { create(:crew_member) }
  let!(:bus_member) { create(:bus_member, crew_member: responsible, bus: bus) }
  let!(:check_books) { create_list(:check_book, 2) }

  describe "POST /pos_api/revenues" do
    before do
      _check_books, total_income = build_check_books check_books
      @params = { user_id: pos_user.id, cash_register_id: cash_register.id, bus_id: bus.id,
                  responsible_id: responsible.id,
                  revenue: { total_income: total_income, total_expenditure: 0, revenue: total_income },
                  checkbooks: _check_books,
                  members_attributes: [ { crew_member_id: responsible.id } ]
      }
    end
    context "sending revenue shortages" do
      describe "responsible ids" do
        context "missing ids" do
          before do
            @params.deep_merge!({
                                    revenue_shortages_attributes: [ { amount: 2000 } ]
                                })
            post pos_api_revenues_path, @params
          end
          it_behaves_like "a failed revenue process", { name: "revenue_shortage", key: "revenue_shortages.responsible" }
        end
        context "non existent ids" do
          before do
            @params.deep_merge!({
                                    revenue_shortages_attributes: [ { responsible_id: 1234, amount: 2000 } ]
                                })
            post pos_api_revenues_path, @params
          end
          it_behaves_like "a failed revenue process", { name: "revenue_shortage", key: "revenue_shortages.responsible" }
        end
        context "when ids are repeated" do
          before do
            @params.deep_merge!({
                                    revenue_shortages_attributes: [
                                        { responsible_id: responsible.id, amount: 1 },
                                        { responsible_id: responsible.id, amount: 1 }
                                    ]
                                })
            post pos_api_revenues_path, @params
          end
          it_behaves_like "a failed revenue process", { name: "responsible id", key: "revenue_shortages.responsible_id" }
        end
        context "when id doesn't belong to crew" do
          let!(:other_responsible) {create(:crew_member)}
          before do
            total_income = @params[:revenue][:total_income]
            @params.deep_merge!({
                                    revenue_shortages_attributes: [ { responsible_id: other_responsible.id, amount: total_income/10 } ]
                                })
            post pos_api_revenues_path, @params
          end
          it_behaves_like "a failed revenue process", { name: "responsible id", key: "revenue_shortages.responsible_id" }
        end
        context "when id is valid" do
          it "creates revenue" do
            total_income = @params[:revenue][:total_income]
            @params.deep_merge!({
                                    revenue_shortages_attributes: [ { responsible_id: responsible.id, amount: total_income/10 } ]
                                })
            post pos_api_revenues_path, @params
            revenue_params = @params[:revenue].merge(bus_id: bus.id, responsible_id: responsible.id)
            expect(exists_revenue? revenue_params).to be_true
          end
        end
      end
      describe "shortages should not exist when revenue" do
        let!(:expenditure) {create :expenditure}
        context "is negative" do
          before do
            total_income = @params[:revenue][:total_income]
            @params.deep_merge!({
                                    revenue_expenditures_attributes: [{ expenditure_id: expenditure.id, value: total_income+1 }],
                                    revenue: {total_income: total_income, total_expenditure: total_income+1, revenue: -1},
                                    revenue_shortages_attributes: [ { responsible_id: responsible.id, amount: 2000 } ]
                                })
            post pos_api_revenues_path, @params
          end
          it_behaves_like "a failed revenue process", { name: "revenue_shortage", key: "revenue_shortages.total_amount" }
        end
        context "is 0" do
          before do
            total_income = @params[:revenue][:total_income]
            @params.deep_merge!({
                                    revenue_expenditures_attributes: [{ expenditure_id: expenditure.id, value: total_income }],
                                    revenue: {total_income: total_income, total_expenditure: total_income, revenue: 0},
                                    revenue_shortages_attributes: [ { responsible_id: responsible.id, amount: 2000 } ]
                                })
            post pos_api_revenues_path, @params
          end
          it_behaves_like "a failed revenue process", { name: "revenue_shortage", key: "revenue_shortages.total_amount" }
        end
      end

      describe "shortages could not exceed revenue" do
        before do
          total_income = @params[:revenue][:total_income]
          @params.deep_merge!({
                                  revenue_shortages_attributes: [ { responsible_id: responsible.id, amount: total_income+1 } ]
                              })
          post pos_api_revenues_path, @params
        end
        it_behaves_like "a failed revenue process", { name: "revenue_shortage", key: "revenue_shortages.total_amount" }
      end

      describe "shortages should have an amount" do
        before do
          @params.deep_merge!({
                                  revenue_shortages_attributes: [ { responsible_id: responsible.id} ]
                              })
          post pos_api_revenues_path, @params
        end
        it_behaves_like "a failed revenue process", { name: "amount", key: "revenue_shortages.amount" }
      end
      describe "shortages should have positive amount" do
        before do
          @params.deep_merge!({
                                  revenue_shortages_attributes: [ { responsible_id: responsible.id, amount: -1000} ]
                              })
          post pos_api_revenues_path, @params
        end
        it_behaves_like "a failed revenue process", { name: "amount", key: "revenue_shortages.amount" }
      end

    end
  end
end