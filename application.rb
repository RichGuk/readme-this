require 'rubygems'
require 'bundler'
require 'bundler/setup'

require 'sinatra'
Bundler.setup(:default, (ENV['RACK_ENV'] || :deveopment))
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
  puts params[:format]
  puts params[:uploaded_readme]
  # Uploaded document takes priority over the pasted one.
  if file = params[:uploaded_readme]
    ext = File.extname(file[:filename]).gsub('.', '').downcase
    if %w(rdoc textile markdown md mkd mkdn rst asscidoc).include?(ext)
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

  begin
  @contents = GitHub::Markup.render("README.#{@readme.format}", @readme.contents)
  rescue
    raise Sintra::NotFound
  end

  @contents = @contents.gsub(/(<pre[^>]*>)\n+[^\w]*/, '\1')
  haml :readme
end
