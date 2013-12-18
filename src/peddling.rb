# -*- encoding: utf-8 -*-

require "find"
require "json"

class Peddling
  attr_reader :date

  def initialize(data)
    if not data.kind_of?(Hash)
      return nil
    end
    set_data_(data)
  end

  def has_correct_value?
    if @date
      return true
    end
  end

  def to_hash
    wdays = ["日", "月", "火", "水", "木", "金", "土"]
    schedule = {}
    first_wday = wdays[@first_date.wday]
    if ! @last_date.nil?
      last_wday = wdays[@last_date.wday]
      schedule["date"] = @first_date.strftime("%Y年%m月%d日") \
                        + "(#{first_wday})から"
      if @first_date.year != @last_date.year
        schedule["date"] += @last_date.strftime("%Y年%m月%d日") \
                        + "(#{last_wday})まで"
      elsif @first_date.month != @last_date.month
        schedule["date"] += @last_date.strftime("m月%d日") \
                        + "(#{last_wday})まで"
      else
        schedule["date"] += @last_date.strftime("%d日") \
                        + "(#{last_wday})まで"
      end
    else
      schedule["date"] = @first_date.strftime("%Y年%m月%d日") \
                        + "(#{first_wday})"
    end
    schedule["datetime"] = @first_date
    schedule["place"] = @place
    schedule["subject"] = @subject
    schedule["message"] = @message
    schedule["address"] = @address
    schedule["map"] = @map
    schedule["url"] = @url
    schedule["priority"] = @priority
    return schedule
  end

  def set_data_(data)
    parse_and_set_date_(data["date"], data["last-date"])
    @place = data["place"]
    @subject = data["subject"]
    @message = data["message"]
    @address = data["address"]
    @map = data["map"]
    @url = data["url"]
    @priority = data["priority"] ||= 3
  end

  def parse_and_set_date_(date, last_date)
    d = date.split("/")
    @first_date = Time.local(d[0], d[1], d[2])
    if ! last_date.nil?
      d = last_date.split("/")
      @last_date = Time.local(d[0], d[1], d[2])
    end
    @date = if @last_date.nil?
              @first_date
            else
              @last_date
            end
  end
  protected :parse_and_set_date_, :set_data_
end

def read_peddrings(directory)
  peddlings = {}

  for filename in Find.find(directory)
    if FileTest::file?(filename)
      peddlings.merge!(parse_peddling(filename))
    end
  end
  return peddlings
end

def parse_peddling(filename)
  open(filename) do |f|
    peddlings = {}
    begin
      datas = JSON.load(f)
      if datas.kind_of?(Array)
        for data in datas
          peddling = Peddling.new(data)
          if peddling.has_correct_value?
            peddlings[peddling.date] = peddling
          end
        end
      else
        peddling = Peddling.new(datas)
        if peddling.has_correct_value?
          peddlings[peddling.date] = peddling
        end
      end
    rescue JSON::ParserError
      p filename
      p $!
    end
    return peddlings
  end
end

def export_nearby_peddling(schedules)
  datas = schedules.select {|date, peddling| date > (Time.now - (60 * 60 * 24 * 2))}
  sorted_datas = datas.sort

  schedule_hash = {"nearby_event_list" => []}
  sorted_datas[0..5].each do
    |date, p|
    if p.has_correct_value?
      schedule_hash["nearby_event_list"] << p.to_hash
    end
  end
  return JSON.generate(schedule_hash)
end

def export_future_peddling(schedules)
  datas = schedules.select {|date, peddling| date > (Time.now - (60 * 60 * 24 * 2))}
  sorted_datas = datas.sort
  schedule_hash = {"future_event_list" => []}
  sorted_datas.each do
    |date, p|
    if p.has_correct_value?
      schedule_hash["future_event_list"] << p.to_hash
    end
  end
  return JSON.generate(schedule_hash)
end

def export_past_peddling(schedules)
  datas = schedules.select {|date, peddling| date < Time.now}
  sorted_datas = datas.sort
  sorted_datas.reverse!
  schedule_hash = {"past_event_list" => []}
  sorted_datas.each do
    |date, p|
    if p.has_correct_value?
      schedule_hash["past_event_list"] << p.to_hash
    end
  end
  return JSON.generate(schedule_hash)
end

