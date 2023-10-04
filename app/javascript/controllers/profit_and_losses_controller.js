import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['budgetedAmount']

  toggle_budgeted_amounts(event) {
    event.preventDefault()
    const buttonTarget = event.target
    const budgeted_targets = this.budgetedAmountTargets
    if (buttonTarget.dataset.hidden === 'true') {
      budgeted_targets.forEach((budgetedAmount) => {
        budgetedAmount.classList.remove('hidden')
      })
      buttonTarget.dataset.hidden = 'false'
      buttonTarget.innerHTML = 'Hide Budgeted Amounts'
    } else {
      budgeted_targets.forEach((budgetedAmount) => {
        budgetedAmount.classList.add('hidden')
      })
      buttonTarget.dataset.hidden = 'true'
      buttonTarget.innerHTML = 'Show Budgeted Amounts'
    }
  }
}
