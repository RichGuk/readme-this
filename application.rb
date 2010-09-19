require 'rubygems'
require 'bundler'
Bundler.setup

require 'sinatra'
Bundler.require(:default, (ENV['RACK_ENV'] || :deveopment))

require 'environment'

# not_found do
#   'Not found'
# end

# error do
#   'Doh! error - ' + env['sinatra.error'].name
# end

helpers do
  # add some helpers.
end

get '/' do
  haml :new
end

post '/readme' do

  @readme = Readme.new(params[:readme])
  # Uploaded document takes priority over the pasted one.
  if file = params[:uploaded_readme]
    ext = File.extname(file[:filename]).gsub('.', '').downcase
    if %w(rdoc textile markdown md mkd mkdn).include?(ext)
      @readme.format = ext
      while(line = file[:tempfile].gets)
        puts line
        @readme.contents += line
      end
    end
  end

  # Is this private?
  @readme.private_id = Digest::SHA1.hexdigest("--#{Time.now}--#{@readme.format}--#{@readme.contents}--") if params[:readme_private]

  if @readme.save
    redirect '/' + (@readme.private_id || @readme.id).to_s
  else
    @fail = true
    haml :new
  end
end

get '/:id' do
  @readme = Readme.first(:conditions => [ 'id = ? OR private_id = ?', params[:id], params[:id] ]) or raise Sinatra::NotFound
  # If private check ID matches.
  raise Sinatra::NotFound if !@readme.private_id.nil? && @readme.private_id != params[:id]

  case @readme.format
  when 'rdoc':
    rdoc = RDoc::Markup::ToHtml.new
    @contents = rdoc.convert(@readme.contents)
  when 'textile':
    @contents = RedCloth.new(@readme.contents).to_html
  when 'markdown', 'md', 'mkd', 'mkdn':
    @contents = RDiscount.new(@readme.contents).to_html
  else
    raise Sinatra::NotFound
  end

  @contents = @contents.gsub(/(<pre[^>]*>)\n+[^\w]*/, '\1')
  haml :readme
end
