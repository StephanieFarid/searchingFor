import { Controller } from "@hotwired/stimulus"

// Opens a native <dialog> as a modal. Closes on Cancel, Escape, or backdrop click.
export default class extends Controller {
  static targets = ["dialog", "focus"]

  connect() {
    this.closeBeforeCache = () => this.close()
    document.addEventListener("turbo:before-cache", this.closeBeforeCache)
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.closeBeforeCache)
  }

  open() {
    this.dialogTarget.showModal()
    if (this.hasFocusTarget) this.focusTarget.focus()
  }

  close() {
    if (this.dialogTarget.open) this.dialogTarget.close()
  }

  backdropClose(event) {
    if (event.target === this.dialogTarget) this.close()
  }
}
