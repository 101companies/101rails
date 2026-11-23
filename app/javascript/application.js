// Application entry point, bundled by esbuild (see esbuild.config.mjs).
import Rails from '@rails/ujs';

import $ from 'jquery';
import Popper from 'popper.js';
import 'bootstrap';

// Bootstrap 4's UMD build and some inline view scripts expect these globals.
window.jQuery = window.$ = $;
window.Popper = Popper;

import 'chartkick/chart.js';

import mountReactComponents from './react/mount';

Rails.start();

$(document).ready(() => {
  mountReactComponents();

  $('li.nav-item a.nav-link').click(function () {
    $('li.nav-item a.nav-link').removeClass('active');
    $('li.nav-item').removeClass('active');
  });
});
