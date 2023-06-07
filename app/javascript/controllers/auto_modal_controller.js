import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auto-modal"
export default class extends Controller {
  connect() {
    // console.log("auto-modal--connect");
    this.modal = new bootstrap.Modal(this.element)
    this.modal.show()
  }

  // 保存成功時にモーダルを閉じる
  close(event) {
    if (event.detail.success) {
      // console.log("auto-modal--close");
      this.modal = new bootstrap.Modal(this.element)
      this.modal.hide()
    }
  }
}
