import { Controller } from "@hotwired/stimulus"

let callbackCounter = 0

export default class extends Controller {
  static targets = [
    "methodInput",
    "homePanel",
    "inpostPanel",
    "pointNameInput",
    "pointAddressInput",
    "preview",
    "widget"
  ]

  connect() {
    this.registerWidgetCallback()
    this.toggle()
  }

  disconnect() {
    if (this.callbackName && window[this.callbackName]) {
      delete window[this.callbackName]
    }

    if (this.boundWidgetPointSelected && this.hasWidgetTarget) {
      this.widgetTarget.removeEventListener("inpost.geowidget.onpoint", this.boundWidgetPointSelected)
    }
  }

  toggle() {
    const selectedMethod = this.selectedMethod()
    const inpostSelected = selectedMethod === "inpost"
    const homeSelected = selectedMethod === "home_delivery"

    if (this.hasHomePanelTarget) {
      this.homePanelTarget.classList.toggle("hidden", !homeSelected)
      this.homePanelTarget.querySelectorAll("input, textarea").forEach((input) => {
        input.disabled = !homeSelected
      })
    }

    if (this.hasInpostPanelTarget) {
      this.inpostPanelTarget.classList.toggle("hidden", !inpostSelected)
      this.inpostPanelTarget.querySelectorAll("input, textarea").forEach((input) => {
        input.disabled = !inpostSelected
      })
    }

    if (this.hasPointNameInputTarget) {
      this.pointNameInputTarget.required = inpostSelected
    }

    if (this.hasPointAddressInputTarget) {
      this.pointAddressInputTarget.required = inpostSelected
    }

    this.updatePreview()
  }

  updatePreview() {
    if (!this.hasPreviewTarget) return

    const pointSummary = [
      this.hasPointNameInputTarget ? this.pointNameInputTarget.value.trim() : "",
      this.hasPointAddressInputTarget ? this.pointAddressInputTarget.value.trim() : ""
    ].filter(Boolean).join(" - ")

    this.previewTarget.textContent = pointSummary
    this.previewTarget.classList.toggle("hidden", pointSummary.length === 0)
  }

  registerWidgetCallback() {
    if (!this.hasWidgetTarget) return

    callbackCounter += 1
    this.callbackName = `inpostPointSelected${callbackCounter}`
    window[this.callbackName] = (point) => this.applyPoint(point)
    this.widgetTarget.setAttribute("onpoint", this.callbackName)

    this.boundWidgetPointSelected = (event) => this.applyPoint(event.detail || event.point || event)
    this.widgetTarget.addEventListener("inpost.geowidget.onpoint", this.boundWidgetPointSelected)
  }

  applyPoint(rawPoint) {
    const point = rawPoint?.point || rawPoint
    if (!point) return

    const inpostRadio = this.methodInputTargets.find((input) => input.value === "inpost")
    if (inpostRadio) inpostRadio.checked = true

    if (this.hasPointNameInputTarget) {
      this.pointNameInputTarget.value = point.name || point.id || ""
    }

    if (this.hasPointAddressInputTarget) {
      this.pointAddressInputTarget.value = this.extractAddress(point)
    }

    this.toggle()
  }

  extractAddress(point) {
    if (typeof point.address === "string" && point.address.trim().length > 0) {
      return point.address.trim()
    }

    if (point.address && typeof point.address === "object") {
      const addressLines = [point.address.line1, point.address.line2]
        .map((part) => part?.toString().trim())
        .filter(Boolean)

      if (addressLines.length > 0) return addressLines.join(", ")
    }

    const details = point.address_details || {}
    const streetLine = [details.street, details.building_number].filter(Boolean).join(" ").trim()
    const cityLine = [details.post_code, details.city].filter(Boolean).join(" ").trim()

    return [streetLine, cityLine, details.province]
      .map((part) => part?.toString().trim())
      .filter(Boolean)
      .join(", ")
  }

  selectedMethod() {
    return this.methodInputTargets.find((input) => input.checked)?.value
  }
}
