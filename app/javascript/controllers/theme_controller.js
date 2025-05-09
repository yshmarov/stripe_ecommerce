import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Get saved theme or use default
    const theme = localStorage.getItem("theme") || "light"
    document.documentElement.setAttribute("data-theme", theme)

    // Update checkbox if needed
    if (theme === "dark") {
      this.element.checked = true
    }
  }

  toggle() {
    // Change theme
    const theme = this.element.checked ? "dark" : "light"
    document.documentElement.setAttribute("data-theme", theme)

    // Save choice
    localStorage.setItem("theme", theme)
  }
} 