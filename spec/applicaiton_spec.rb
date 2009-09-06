require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'ReadmeThis::Applicaiton' do
  
  def app
    Sinatra::Application
  end
  
  it 'should load the index page successfully' do
    get '/'
    last_response.should be_ok
  end
  
  it 'should contain form on index page' do
    get '/'
    last_response.should have_selector 'form'
  end
  
  describe 'POST with valid data' do
    before do
      post '/readme', :readme => {:contents => 'h1. Header', :format => 'textile'}
    end
    
    it 'should redirect successfully' do
      follow_redirect!
      
      last_request.url.should == 'http://example.org/1'
      last_response.should be_ok
    end
    
    it 'should contain database entry' do
      Readme.first.id.should == 1
    end
    
    it 'should display HTML correctly for the textile document' do
      get '/1'
      last_response.body.should have_selector 'h1', :content => 'Header'
    end
  end
  
  describe 'POST with invalid data' do
    before do
      post '/readme', :readme => {:contents => '', :format => ''}
    end
    
    it 'should not redirect' do
      last_response.redirect?.should == false
    end
    
    it 'should not contain database entry' do
      Readme.first.should == nil
    end
    
    it 'should show error message' do
      last_response.body.should =~ /Something went wrong =\(/
    end
    
    it 'should show form again' do
      last_response.body.should have_selector 'form'
    end
  end
  
  describe 'Supported README formats' do
    it 'should load rdoc' do
      Readme.new(:contents => File.new(File.join(File.dirname(__FILE__), 'data', 'README.rdoc')).read, :format => 'rdoc').save
      
      get '/1'
      last_response.should be_ok
      last_response.body.should have_selector('h1', :content => 'Header 1')
      last_response.body.should have_selector('h2', :content => 'Header 2')
      last_response.body.should have_selector('h3', :content => 'Header 3')
      last_response.body.should have_selector('p', :content => 'Some normal text.')
      last_response.body.should have_selector('a', :href => 'http://github.com', :content => 'github.com')
      last_response.body.should have_selector('pre')
      last_response.body.should =~ /Some normal text with <b>bold<\/b> and <em>emphasised<\/em> text./
    end
    
    it 'should load textile' do
      Readme.new(:contents => File.new(File.join(File.dirname(__FILE__), 'data', 'README.textile')).read, :format => 'textile').save
      
      get '/1'
      last_response.should be_ok
      last_response.body.should have_selector('h1', :content => 'Header 1')
      last_response.body.should have_selector('h2', :content => 'Header 2')
      last_response.body.should have_selector('h3', :content => 'Header 3')
      last_response.body.should have_selector('p', :content => 'Some normal text.')
      last_response.body.should have_selector('a', :href => 'http://github.com', :content => 'github.com')
      last_response.body.should have_selector('pre')
      last_response.body.should =~ /Some normal text with <strong>bold<\/strong> and <em>emphasised<\/em> text./
    end
    
    it 'should load markdown' do
      Readme.new(:contents => File.new(File.join(File.dirname(__FILE__), 'data', 'README.markdown')).read, :format => 'markdown').save
      
      get '/1'
      last_response.should be_ok
      last_response.body.should have_selector('h1', :content => 'Header 1')
      last_response.body.should have_selector('h2', :content => 'Header 2')
      last_response.body.should have_selector('h3', :content => 'Header 3')
      last_response.body.should have_selector('p', :content => 'Some normal text.')
      last_response.body.should have_selector('a', :href => 'http://github.com', :content => 'github.com')
      last_response.body.should have_selector('pre')
      last_response.body.should =~ /Some normal text with <strong>bold<\/strong> and <em>emphasised<\/em> text./
    end
    
    it 'should error if unknown format is loaded' do
      Readme.new(:contents => 'h1. Header', :format => 'w00t').save
      
      get '/1'
      last_response.should_not be_ok
    end
  end
  
end