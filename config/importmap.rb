# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/stimulus", to: "https://ga.jspm.io/npm:@hotwired/stimulus@3.2.2/dist/stimulus.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "@rails/ujs", to: "https://ga.jspm.io/npm:@rails/ujs@7.0.4/lib/assets/compiled/rails-ujs.js"
pin "stimulus-use", to: "https://ga.jspm.io/npm:stimulus-use@0.52.0/dist/index.js"
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"
pin "chartjs-plugin-zoom", to: "https://ga.jspm.io/npm:chartjs-plugin-zoom@2.0.1/dist/chartjs-plugin-zoom.esm.js"
pin "@kurkle/color", to: "https://ga.jspm.io/npm:@kurkle/color@0.3.2/dist/color.esm.js"
pin "chart.js/helpers", to: "https://ga.jspm.io/npm:chart.js@4.4.0/helpers/helpers.js"
pin "hammerjs", to: "https://ga.jspm.io/npm:hammerjs@2.0.8/hammer.js"
