/* eslint no-console:0 */
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//
// To reference this file, add <%= javascript_pack_tag 'application' %> to the appropriate
// layout file, like app/views/layouts/application.html.erb


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// require("@rails/ujs").start()
import '../src/css/style';

import $ from 'jquery';
import 'popper.js';
import 'bootstrap';
import "chartkick/chart.js"

import Turbolinks from 'turbolinks';
Turbolinks.start();

// Support component names relative to this directory:
var componentRequireContext = require.context("components", true);
var ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);

$(document).ready(() => {
  $("li.nav-item a.nav-link").click(function() {
    $("li.nav-item a.nav-link").removeClass('active');
    $("li.nav-item").removeClass('active');
  });
});
