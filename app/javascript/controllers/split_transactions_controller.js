import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'amountTotal',
    'parentAmount',
    'rowTemplate',
    'splitTransactionAmount',
    'splitTransactionDestroy',
    'splitTransactionsTable',
  ]

  connect() {
    this.update_total()
  }

  new_line(event) {
    event.preventDefault()
    const clone = this.rowTemplateTarget.content.cloneNode(true)
    this.splitTransactionsTableTarget.append(clone)
  }

  remove_line(event) {
    event.preventDefault()
    const target = event.target
    const transactionId = target.dataset.transactionId
    if (transactionId) {
      this.splitTransactionDestroyTargets.forEach((destroyTarget) => {
        if (destroyTarget.dataset.transactionId === transactionId) {
          destroyTarget.checked = true
          destroyTarget.closest('.js-split-transaction-row').classList.add('hidden')
        }
      })
    } else {
      this.splitTransactionsTableTarget.removeChild(target.closest('.js-split-transaction-row'))
    }
    this.update_total()
  }

  update_total() {
    const amounts = this.splitTransactionAmountTargets
    let total = 0
    let suffix = ''

    amounts.forEach((amount) => {
      const parsed = parseFloat(amount.value)
      const row = amount.closest('.js-split-transaction-row')
      if (!row.classList.contains('hidden') && !isNaN(parsed)) {
        total = total + parsed
      }
    })

    if (total != parseFloat(this.parentAmountTarget.innerHTML.replace('$', ''))) {
      this.amountTotalTarget.classList.add('text-red-700')
      suffix = ' (must match original transaction amount)'
    } else {
      this.amountTotalTarget.classList.remove('text-red-700')
    }

    const formatted = Intl.NumberFormat(
      'en-us',
      { style: 'currency', currency: 'USD' }
    ).format(total)

    this.amountTotalTarget.innerHTML = formatted + suffix
  }
}
