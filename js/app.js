$(function () {
  var pixelRatio = !!window.devicePixelRatio ? window.devicePixelRatio : 1;
  if (pixelRatio > 1) {
    $("img").each(function(idx, el){
      el = $(el);
      if (el.attr("data-2x")) {
        el.attr("data-src-orig", el.attr("src"));
        var file = el.attr("src").match(/(.*)(\.png|jpg|jpeg)$/);
        if (file && file.length === 3) {
          el.attr("src", file[1] + "@2x" + file[2]);  
        }
      }
    });
  }
});
