require 'date'
require 'yaml'

class Post

  attr_reader :slug, :date, :year, :month, :i_month, :day, :i_day, :short_year,
  :hour, :minute, :second, :title, :slug, :categories

  FILENAME_SLUG_REGEX = /^_posts\/[0-9]{4}\-[0-9]{2}\-[0-9]{2}\-([A-Za-z0-9\-\s]*)(\.[a-z]*|\/)?$/

  def initialize(filename, contents)
    @filename = filename
    @data = parse_contents(contents)
  end

  def parse_contents(contents)
    front = contents.split(/---\s*\n/)[1]
    YAML.load(front)
  end

  def categories
    category_set = Set.new
    Array(@data["categories"] || []).each do |category|
      category_set << category.to_s.downcase
    end
    category_set.to_a.join("/")
  end

  def front_matter
    @data
  end

  def permalink
    @data['permalink']
  end

  def slug
    @data['slug'] || FILENAME_SLUG_REGEX.match(@filename)[1]
  end

  def title
    slug
  end

  def post_date
    Date.parse( @data['date'] || @filename )
  end

  def date
    post_date.strftime("%Y-%m-%d")
  end

  def year
    post_date.strftime("%Y")
  end

  def month
    post_date.strftime("%m")
  end

  def day
    post_date.strftime("%d")
  end

  def hour
    post_date.strftime("%H")
  end

  def minute
    post_date.strftime("%M")
  end

  def second
    post_date.strftime("%S")
  end

  def i_day
    post_date.strftime("%-d")
  end

  def i_month
    post_date.strftime("%-m")
  end

  def short_month
    post_date.strftime("%b")
  end

  def short_year
    post_date.strftime("%y")
  end

  def y_day
    post_date.strftime("%j")
  end

end