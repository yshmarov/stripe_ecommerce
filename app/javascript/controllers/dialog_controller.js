import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.dialog = document.getElementById('search-dialog')
  }

  open() {
    document.body.style.overflow = 'hidden'
    this.dialog.showModal()
  }

  close() {
    document.body.style.overflow = 'auto'
    this.dialog.close()
  }

  clickOutside(event) {
    if (event.target === this.dialog) {
      this.close()
    }
  }
}
