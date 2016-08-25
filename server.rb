require 'base64'

class Server < Sinatra::Application

  configure do
    %w( root_url github_access_token github_user github_repo ).each do |v|
      set v.to_sym, ENV.fetch(v.to_s.upcase)
    end
  end

  get '/' do
    'Webhook Mentions endpoint. See https://github.com/barryf/webhook-mentions for further information.'
  end

  post '/' do
    require_built_build
    commit = get_commit(params['build']['commit'])
    commit['files'].each do |file|
      next unless file_is_post?(file)
      process_file(file)
    end
    status 200
  end

  def require_built_build
    unless params.has_key?('build') && params['build'].has_key?('status') &&
        params['build']['status'] == 'built'
      halt "Request must contain successful GitHub Pages build payload."
    end
  end

  def process_file(file)
    logger.info "Processing file #{file['filename']} (#{file['status']})"
    url = absolute_url(post_url(file['filename']))
    headers 'Location' => url
    logger.info "URL for #{file['filename']} is #{url}"
    Webmention::Client.new(url).send_mentions
    logger.info "Sent webmention(s) from #{url}"
  end

  def file_is_post?(file)
    file['filename'].start_with?('_posts/')
  end

  def get_commit(sha)
    octokit.commit(github_full_repo, sha)
  end

  def get_file_contents(filename)
    base64_contents = octokit.contents(github_full_repo, { path: filename }).content
    Base64.decode64(base64_contents)
  end

  def style_to_template(style)
    case style.to_sym
    when :pretty
      "/:categories/:year/:month/:day/:title/"
    when :none
      "/:categories/:title.html"
    when :date
      "/:categories/:year/:month/:day/:title.html"
    when :ordinal
      "/:categories/:year/:y_day/:title.html"
    else
      style.to_s
    end
  end

  def get_config_permalink_style
    config_yaml = get_file_contents('_config.yml')
    config = YAML.load(config_yaml)
    style = config['permalink'] || 'date'
    permalink_style = style_to_template(style)
    logger.info "Permalink style is #{permalink_style}"
    permalink_style
  end

  def octokit
    @octokit ||= Octokit::Client.new(access_token: settings.github_access_token)
  end

  def github_full_repo
    "#{settings.github_user}/#{settings.github_repo}"
  end

  def permalink_style
    @permalink_style ||= get_config_permalink_style
  end

  def post_url(filename)
    contents = get_file_contents(filename)
    post = Post.new(filename, contents)
    unless post.permalink.nil?
      return post.permalink
    end
    placeholders = {}
    [ :slug, :date, :year, :month, :i_month, :day, :i_day, :short_year,
        :hour, :minute, :second, :title, :slug, :categories ].each do |ph|
      placeholders[ph] = post.send(ph)
    end
    permalink = Jekyll::URL.new({
      template: permalink_style,
      placeholders: placeholders
    }).to_s
  end

  def absolute_url(relative_url)
    slash = relative_url.start_with?("/") ? "" : "/"
    settings.root_url + slash + relative_url
  end

end
