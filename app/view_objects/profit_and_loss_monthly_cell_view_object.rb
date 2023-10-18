class ProfitAndLossMonthlyCellViewObject
  attr_reader :amount, :budgeted, :difference, :inverse, :month, :view_context, :year

  def initialize(amount:, budgeted:, month:, view_context:, year:, inverse: false)
    @amount = amount
    @budgeted = budgeted
    @inverse = inverse
    @month = month
    @view_context = view_context
    @year = year
    @difference = budgeted - amount
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
      elsif (amount <= budgeted && !inverse) || (amount >= budgeted && inverse)
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
    if (month.blank? && year.eql?(Date.current.year)) || month.eql?(Date.current.month)
      partial_notifier = ' to date'
    end

    spent = difference < 0 ? 'Over' : 'Under'

    "#{spent} by #{difference_currency} (#{budgeted_currency} budgeted#{partial_notifier})"
  end
end