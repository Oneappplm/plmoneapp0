# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "ahoy", to: "ahoy.js"
pin_all_from "app/javascript/controllers", under: "controllers"
