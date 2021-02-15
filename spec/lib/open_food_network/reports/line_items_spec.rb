require 'spec_helper'
require 'open_food_network/reports/line_items'

describe OpenFoodNetwork::Reports::LineItems do
  subject(:reports_line_items) { described_class.new(order_permissions, params) }

  # This object lets us add some test coverage despite the very deep coupling between the class
  # under test and the various objects it depends on. Other more common moking strategies where very
  # hard.
  class FakeOrderPermissions
    def initialize(line_item)
      @relation = Spree::LineItem.where(id: line_item.id)
    end

    def visible_line_items
      relation
    end

    def editable_line_items
      line_item = FactoryBot.create(:line_item)
      Spree::LineItem.where(id: line_item.id)
    end

    private

    attr_reader :relation
  end

  class FakeRansackResult
    attr_reader :result

    def initialize(result)
      @result = result
    end
  end

  describe '#list' do
    let!(:order) { create(:order, distributor: create(:enterprise)) }
    let!(:line_item) { create(:line_item, order: order) }

    let(:order_permissions) { FakeOrderPermissions.new(line_item) }
    let(:params) { {} }

    before do
      orders_relation = Spree::Order.where(id: order.id)
      allow(reports_line_items).to receive(:search_orders) { FakeRansackResult.new(orders_relation) }
    end

    it 'returns masked data' do
      line_items = reports_line_items.list
      expect(line_items.first.order.email).to eq(I18n.t('admin.reports.hidden'))
    end
  end
end
