// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import 'controllers'
import Rails from '@rails/ujs'
import "@hotwired/turbo-rails"
import "chartkick"
import "Chart.bundle"
import zoomPlugin from 'chartjs-plugin-zoom'

Chart.register(zoomPlugin);
Rails.start();
