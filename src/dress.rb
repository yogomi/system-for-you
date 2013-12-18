# -*- encoding: utf-8 -*-

require "find"
require "json"

def load_color_localize_hash
  pwd = File.dirname(__FILE__)
  color_localize_hash = {}
  open("#{pwd}/color-localize-hash.json") do |f|
     color_localize_hash = JSON.load(f)
  end
  return color_localize_hash
end

def search_picture_path
  image_path_base = "img/"
  pwd = File.dirname(__FILE__)
  base = pwd + "/../"
  img_directory = base + image_path_base
  img_hash = {}
  for filename in Find.find(img_directory)
    if FileTest::file?(filename)
      extname = File.extname(filename)
      if /^\.JPG|^\.JPEG|^\.jpg$|^\.jpeg$/ =~ extname
        img_hash[File.basename(filename, extname)] = \
                filename.slice(base.length, filename.length)
      end
    end
  end
  return img_hash
end

class Dress
  @@new_dress_limit = Time.now - 60 * 60 * 24 * 30 * 3
  @@color_localize_hash = load_color_localize_hash
  @@picture_path_hash = search_picture_path
  attr_reader :date

  def initialize(data)
    if not data.kind_of?(Hash)
      return
    end
    set_data_(data)
  end

  def has_correct_value?
    if @picture_path
      return true
    end
  end

  def to_hash
    dress = {}
    dress["serial"] = @serial
    dress["new"] = (@date > @@new_dress_limit)
    dress["picture-path"] = @picture_path
    dress["size"] = @size
    dress["color"] = @color
    dress["color-localized"] = @color_localized
    return dress
  end

  def set_data_(data)
    @serial = data["serial"]
    parse_and_set_date_
    search_and_set_picture_path_
    parse_and_set_size_(data["size"])
    parse_and_set_color_(data["color"])
  end

  def parse_and_set_date_()
    d = []
    d << "20" + @serial[2..3]
    d << @serial[4..5]
    @date = Time.local(d[0], d[1])
  end

  def search_and_set_picture_path_
    @picture_path = @@picture_path_hash[@serial]
  end

  def parse_and_set_size_(size)
    @size = size
  end

  def parse_and_set_color_(color)
    @color = color.split("/")
    @color_localized = []
    @color.each do
      |c|
      if @@color_localize_hash[c].nil?
        @color_localized << c
      else
        @color_localized << @@color_localize_hash[c]
      end
    end
  end

  protected :parse_and_set_date_ \
          , :search_and_set_picture_path_ \
          , :parse_and_set_size_ \
          , :parse_and_set_color_ \
          , :set_data_
end

def read_dresses(directory)
  dresses = []
  for filename in Find.find(directory)
    if FileTest::file?(filename)
      dresses.concat(parse_dress(filename))
    end
  end
  return dresses
end

def parse_dress(filename)
  open(filename) do |f|
    dresses = []
    begin
      datas = JSON.load(f)
      if datas.kind_of?(Array)
        for data in datas
          dress = Dress.new(data)
          if dress.has_correct_value?
            dresses << dress
          end
        end
      else
        dress = Dress.new(datas)
        if dress.has_correct_value?
          dresses << dress
        end
      end
    rescue JSON::ParserError
# TODO エラー処理
      p filename
      p $!
    end
    return dresses
  end
end

def export_dress_list(dresses)
  dress_list = []
  dresses.each do
    |dress|
    if dress.has_correct_value?
      dress_list << dress.to_hash
    end
  end
  return JSON.generate(dress_list)
end
