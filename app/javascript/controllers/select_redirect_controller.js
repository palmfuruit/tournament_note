import {Controller} from "@hotwired/stimulus"

// Connects to data-controller="select-redirect"
export default class extends Controller {
    static values = {url: String, query: String};
    static targets = [ "query" ]

    connect() {
    }

    jump() {
        // console.log("select-redirect #jump() entry");
        fetch(this.urlValue  + "?" + this.queryValue + "=" + this.queryTarget.value)
            .then(response => response.text())
            .then(message => Turbo.renderStreamMessage(message));
    }
}