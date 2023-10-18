class ProfitAndLossYearlyCellViewObject
  attr_reader :amount, :amount_to_date, :budgeted, :difference, :inverse, :month, :view_context, :year

  def initialize(amount:, amount_to_date:, budgeted:, month:, view_context:, year:, inverse: false)
    @amount = amount
    @amount_to_date = amount_to_date
    @budgeted = budgeted
    @inverse = inverse
    @month = month
    @view_context = view_context
    @year = year
    @difference = budgeted - amount_to_date
  end

  def render_cell
    amount_display = view_context.content_tag(
      :div,
      class: bg_color,
      title: over_under,
    ) { amount.zero? ? '-' : view_context.number_to_currency(amount) }

    amount_display = amount_display + view_context.content_tag(
      :div,
      class: "#{bg_color} text-xs hidden",
      data: { profit_and_losses_target: 'budgetedAmount' },
    ) { view_context.number_to_currency(budgeted) }

    amount_display
  end

  private

  def bg_color
    @bg_color ||= begin
      if difference.abs <= budgeted * 0.05
        'bg-yellow-100'
      elsif (amount_to_date <= budgeted && !inverse) || (amount_to_date >= budgeted && inverse)
        'bg-green-100'
      else
        'bg-red-100'
      end
    end
  end

  def budgeted_currency
    view_context.number_to_currency(budgeted)
  end

  def difference_currency
    view_context.number_to_currency(difference.abs)
  end

  def over_under
    spent = difference < 0 ? 'Over' : 'Under'

    "#{spent} by #{difference_currency} (#{budgeted_currency} budgeted)"
  end
end