var width = 500;
var height = 300;

$(document).ready(function() {

  $.getJSON('http://worker.101companies.org/data/dumps/moretagclouds/languages.json', function(data) {

    var word_numbers = $.map(data, function(x) {
      return x;
    });

    var word_number = word_numbers.reduce(function(x, y) {
      return x + y;
    });

    var words = $.map(data, function(_, x) {
      return x;
    });

    var step = Math.max.apply(null, word_numbers) / 6

    var fill = d3.scale.category20();

    d3.layout.cloud().size([width, height])
    .words(words.map(function(d) {
      var factor = 10;
      var count = data[d];
      var css = count / step;
      factor += css*50;

      return {text: d, size: factor};
    }))
    .rotate(function() { return ~~(Math.random() * 2) * 90; })
    .font("Impact")
    .fontSize(function(d) { return d.size; })
    .on("end", draw)
    .start();

    function draw(words) {
      d3.select(".tag-cloud").append("svg")
      .attr("width", width)
      .attr("height", height)
      .append("g")
      .attr("transform", "translate(" + width/2 + "," + height/2 + ")")
      .selectAll("text")
      .data(words)
      .enter().append("text")
      .attr("text-anchor", "middle")
      .style("font-size", function(d) { return d.size + "px"; })
      .style("font-family", "Impact")
      .style("fill", function(d, i) { return fill(i); })
      .attr("text-anchor", "middle")
      .on("click", function(d) {
        window.location.href = 'http://101companies.org/wiki/Technology:' + d.text;
      })
      .attr("transform", function(d) {
        return "translate(" + [d.x, d.y] + ")rotate(" + d.rotate + ")";
      })
      .text(function(d) { return d.text; });
    }

  });

});
