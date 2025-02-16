import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.dialog = document.getElementById('search-dialog')
  }

  open() {
    this.dialog.showModal()
  }

  close() {
    this.dialog.close()
  }
}
