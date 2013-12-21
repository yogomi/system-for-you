function load_header() {
  $("#header").load("header.html");
}

function append_event() {
  var event = $("<article class='event sticker'></article>");
  if(this["subject"]) {
    event.append("<h3>" + this["subject"] + "</h3>");
  }
  event.append("<time datetime=\"" + this["datetime"]
              + "\">" + this["date"] + "</time>");
  if(this["message"]) {
    event.append("<p class='message'>"
                + this["message"] + "</p>");
  }
  if(this["place"]) {
    event.append("<h4 class='place'>"
                + this["place"] + "</h4>");
  }
  if(this["address"]) {
    event.append("<p class='address'>"
                + this["address"] + "</p>");
  }
  if(this["url"]) {
    event.append("<a class='url' href=\"" + this["url"]
                + "\">ホームページへ</a>");
  }
  event.appendTo("#events");
}

function load_nearby_event() {
  $("#events").empty();
  $.getJSON("src/get_nearby_event.rb", function(datas) {
    if (datas.nearby_event_list.length > 0) {
      $("#events").append("<h2 id='news-header'>News!</h2>");
    }
    $.each(datas.nearby_event_list, append_event);
  })
}

function load_future_event() {
  $("#events").empty();
  $.getJSON("src/get_future_event.rb", function(datas) {
    $.each(datas.future_event_list, append_event);
  })
}

function load_past_event() {
  $("#events").empty();
  $.getJSON("src/get_past_event.rb", function(datas) {
    $.each(datas.past_event_list, append_event);
  })
}

function append_dress(filter) {
  return function () {
    if (filter(this)) {
      var dress = $("<a href=\"" + this["picture-path"]
                + "\" class=\"dress\" title=\"" + this["serial"]
                + "\"></a>");
      dress.append("<img src=\"" + this["picture-path"]
                    + "\" style=\"height:200px;\" alt=\"image\" />");
      dress.appendTo("#dresses");
    }
  }
}

function show(filter) {
  $("#dresses").empty();
  builder = append_dress(filter);
  if (typeof dress_data === "undefined") {
    $.getJSON("src/get_dress_list.rb", function(datas) {
      dress_data = datas;
      $.each(dress_data, builder);
      $(".dress").swipebox();
    });
  } else {
    $.each(dress_data, builder);
    $(".dress").swipebox();
  }
}

function show_all_dress() {
  show(function (data){return true;});
}

function show_new_dress() {
  show(function (data) {
    return data["new"];
  })
}
