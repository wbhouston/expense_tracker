import { Controller } from "@hotwired/stimulus"
import { useClickOutside } from "stimulus-use";

export default class extends Controller {
  static targets = ['menu']

  connect() {
    useClickOutside(this)
  }

  clickOutside(event) {
    this.close()
  }

  close() { this.menuTarget.classList.add('hidden') }

  show() { this.menuTarget.classList.remove('hidden') }

  toggle() {
    if (this.menuTarget.classList.contains('hidden')) {
      this.show()
    } else {
      this.close()
    }
  }
}
