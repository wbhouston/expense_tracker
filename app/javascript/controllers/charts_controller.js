import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['chartContainer']

  connect() {
    this.chartContainerTargets.forEach(
      (container) => this.loadChart(container)
    )
  }

  async loadChart(container) {
    const url = container.dataset.url
    const response = await fetch(url)
    let chart_config = await response.json()

    chart_config['options']['scales']['x']['ticks']['callback'] =
      function (value, index, ticks) {
        return new Date(value).toLocaleDateString('en-US', { month: 'short', year: 'numeric' })
      }

    container.innerHTML = ''

    const chart = new Chart(
      container,
      chart_config,
    )
  }
}