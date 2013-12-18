function load_header() {
  $("#header").load("header.html");
}

function append_event() {
  event = $("<article class='event'></article>");
  if(this["subject"]) {
    event.append("<h2>" + this["subject"] + "</h2>");
  }
  event.append("<time datetime=\"" + this["datetime"]
              + "\">" + this["date"] + "</time>");
  if(this["message"]) {
    event.append("<p class='message'>"
                + this["message"] + "</p>");
  }
  if(this["place"]) {
    event.append("<h3 class='place'>"
                + this["place"] + "</h3>");
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
