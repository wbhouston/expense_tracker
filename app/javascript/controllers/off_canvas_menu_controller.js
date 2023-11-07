import { Controller } from "@hotwired/stimulus"
import { useClickOutside } from "stimulus-use";

export default class extends Controller {
  static targets = ['menu', 'menuContent']

  connect() {
    useClickOutside(this, { element: this.menuContentTarget })
  }

  clickOutside() {
    this.close()
  }

  close() {
    this.menuTarget.classList.add('hidden')
  }

  open() {
    this.menuTarget.classList.remove('hidden')
  }
}
