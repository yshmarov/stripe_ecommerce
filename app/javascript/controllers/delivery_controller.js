import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="delivery"
export default class extends Controller {
  static targets = ["radio", "inpostWidget", "selectedPoint", "orderUrl"]

  connect() {
    window.handleInpostPointSelected = this.pointSelected.bind(this)
    if (this.hasInpostWidgetTarget && !this.inpostWidgetTarget.classList.contains("hidden")) {
      this.loadGeoWidget()
    }
  }

  disconnect() {
    delete window.handleInpostPointSelected
  }

  select(event) {
    const deliveryType = event.target.value

    if (deliveryType === "in_post") {
      this.inpostWidgetTarget.classList.remove("hidden")
      this.loadGeoWidget()
    } else {
      this.inpostWidgetTarget.classList.add("hidden")
      this.selectedPointTarget.classList.add("hidden")
    }

    this.saveDelivery({ delivery_type: deliveryType })
  }

  pointSelected(point) {
    const name = point.name
    const address = [point.address.line1, point.address.line2].filter(Boolean).join(", ")

    const nameEl = document.createElement("p")
    nameEl.className = "text-sm font-medium"
    nameEl.textContent = name

    const addrEl = document.createElement("p")
    addrEl.className = "text-xs text-base-content/60"
    addrEl.textContent = address

    this.selectedPointTarget.classList.remove("hidden")
    this.selectedPointTarget.replaceChildren(nameEl, addrEl)

    this.saveDelivery({
      delivery_type: "in_post",
      inpost_point_name: name,
      inpost_point_address: address
    })
  }

  saveDelivery(params) {
    const url = this.orderUrlTarget.value
    const csrfToken = document.querySelector("meta[name='csrf-token']").content

    fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ order: params })
    })
  }

  loadGeoWidget() {
    if (document.querySelector("script[src*='inpost-geowidget']")) return

    const link = document.createElement("link")
    link.rel = "stylesheet"
    link.href = "https://geowidget.inpost.pl/inpost-geowidget.css"
    document.head.appendChild(link)

    const script = document.createElement("script")
    script.src = "https://geowidget.inpost.pl/inpost-geowidget.js"
    document.head.appendChild(script)
  }
}
