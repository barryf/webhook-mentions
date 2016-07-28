require 'date'

class Server < Sinatra::Application
  helpers Sinatra::LinkHeader

  configure do
    set :server, :puma
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
    url = url_from_filename(file['filename'])
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

  #def get_file_contents(filename)
  #  octokit.contents(github_full_repo, filename).content
  #end

  def octokit
    @octokit ||= Octokit::Client.new(access_token: settings.github_access_token)
  end

  def github_full_repo
    "#{settings.github_user}/#{settings.github_repo}"
  end

  def url_from_filename(filename)
    # TODO: adapt to the permalink config
    # e.g. "_posts/2016-07-18-something-from-quill.md"
    date = Date.parse(filename)
    r = /^_posts\/[0-9]{4}\-[0-9]{2}\-[0-9]{2}\-([A-Za-z0-9-]*)\./
    slug = r.match(filename)[1]
    "#{settings.root_url}/#{date.strftime('%Y/%m/%d')}/#{slug}.html"
  end

end
