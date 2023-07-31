import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="auto-modal"
export default class extends Controller {

    connect() {
        console.log("auto-modal--connect");
        this.modal = new bootstrap.Modal(this.element);
        this.modal.show();
    }

    // 保存成功時にモーダルを閉じる
    close_if_success(event) {
        console.log("auto-modal--close_if_success");
        if (event.detail.success) {
            console.log("event-success");
            this.modal.hide();
        }
    }

    close(event) {
        console.log("auto-modal--close");
        this.modal.hide();
    }
}
