import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="element-remove"
export default class extends Controller {
  remove() {
    this.element.remove()
  }
}
