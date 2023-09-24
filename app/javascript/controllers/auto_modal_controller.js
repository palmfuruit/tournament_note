import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="auto-modal"
export default class extends Controller {

    connect() {
        this.modal = new bootstrap.Modal(this.element);
        this.modal.show();
    }

    // 保存成功時にモーダルを閉じる
    close_if_success(event) {
        if (event.detail.success) {
            this.modal.hide();
        }
    }

    close(event) {
        this.modal.hide();
    }
}
