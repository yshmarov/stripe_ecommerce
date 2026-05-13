import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['inpostFields', 'pointName', 'pointAddress', 'pointSummary', 'geowidget']

  connect() {
    this.toggle()
    this.connectGeowidget()
  }

  toggle() {
    if (!this.hasInpostFieldsTarget) return

    this.inpostFieldsTarget.classList.toggle('hidden', this.selectedDeliveryMethod !== 'inpost')
  }

  connectGeowidget() {
    if (!this.hasGeowidgetTarget) return

    this.geowidgetTarget.addEventListener('inpost.geowidget.init', (event) => {
      event.detail.api.addPointSelectedCallback((point) => this.selectPoint(point))
    })
  }

  selectPoint(point) {
    const pointName = point.name || ''
    const pointAddress = [point.address?.line1, point.address?.line2].filter(Boolean).join(', ')

    this.pointNameTarget.value = pointName
    this.pointAddressTarget.value = pointAddress
    this.pointSummaryTarget.textContent = [pointName, pointAddress].filter(Boolean).join(' - ')
  }

  get selectedDeliveryMethod() {
    return this.element.querySelector('input[name="order[delivery_method]"]:checked')?.value
  }
}
