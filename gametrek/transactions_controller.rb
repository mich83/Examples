module Api
  module Users
    class TransactionsController < ApiController
      def index
        transactions = TransactionFilter.new(current_user, params)
        render json: transactions.filter_grouped
      end
    end
  end
end
