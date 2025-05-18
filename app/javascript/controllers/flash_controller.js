import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["message"]

  connect() {
    setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  dismiss() {
    this.element.classList.add("animate-fade-out-right")
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
} 