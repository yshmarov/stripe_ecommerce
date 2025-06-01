import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['message']

  connect() {
    // Ensure initial styles are applied, then trigger transition
    requestAnimationFrame(() => {
      this.element.classList.remove('opacity-0', '-translate-y-full')
      this.element.classList.add('opacity-100', 'translate-y-0')
    })

    setTimeout(() => {
      this.dismiss()
    }, 5000)
  }

  dismiss() {
    // Transition to invisible and off-screen
    this.element.classList.remove('opacity-100', 'translate-y-0')
    this.element.classList.add('opacity-0', '-translate-y-full')

    // Remove element after transition (duration is 300ms from Tailwind classes)
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
