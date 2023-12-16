//= require jquery3
//= require popper
//= require bootstrap-sprockets
import "@hotwired/turbo-rails"
import "@fortawesome/fontawesome-free"
import "controllers"

// BootstrapのTooltipを全ページ有効にする
document.addEventListener("turbo:load", function () {
    // This code is copied from Bootstrap's docs. See link below.
    const tooltipTriggerList = document.querySelectorAll('[data-bs-toggle="tooltip"]')
    const tooltipList = [...tooltipTriggerList].map(tooltipTriggerEl => new bootstrap.Tooltip(tooltipTriggerEl))
});