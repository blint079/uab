require 'mechanize'
require 'oauth'
CONSUMER_KEY = 'd779d257c3a878add0efd8ed96d29781'
CONSUMER_SECRET = 'b824a6349c2859f6261e0f1c2f2689d1'
URL = 'http://www.aspectsofdecor.com/'
ADMIN_USERNAME = 'data'
ADMIN_PASSWORD = 'C0ff33!'
module Token
  def create_consumer
    OAuth::Consumer.new(
      CONSUMER_KEY,
      CONSUMER_SECRET,
      :request_token_path => '/oauth/initiate',
      :authorize_path=>'/admin/oauth_authorize',
      :access_token_path=>'/oauth/token',
      :site => URL
    )
  end

  def request_token(args = {})
    args[:consumer].get_request_token(:oauth_callback => URL)
  end

  def get_authorize_url(args = {})
    args[:request_token].authorize_url(:oauth_callback => URL)
  end

  def authorize_application(args = {})
	 puts "this is the URL #{args[:authorize_url]}"
    m = Mechanize.new
    m.get(args[:authorize_url]) do |login_page|
      auth_page = login_page.form_with(:action => "#{URL}/index.php/admin/oauth_authorize/index/") do |form|
				puts auth_page
        form.elements[1].value = ADMIN_USERNAME
        form.elements[2].value = ADMIN_PASSWORD
      end.submit
      authorize_form = auth_page.forms[0]
      @callback_page = authorize_form.submit
    end
    @callback_page.uri.to_s
  end

  def extract_oauth_verifier(args = {})
    callback_page = "#{args[:callback_page]}".gsub!("#{URL}/?", '')
    callback_page_query_string = CGI::parse(callback_page)
    callback_page_query_string['oauth_verifier'][0]
  end

  def get_access_token(args = {})
    args[:request_token].get_access_token(:oauth_verifier => args[:oauth_verifier])
  end

  def save_tokens_to_json(args = {})
    auth = {}
    auth[:time] = Time.now
    auth[:token] = args[:access_token].token
    auth[:secret] = args[:access_token].secret
    File.open("#{args[:path]}#{args[:filename]}.json", 'w') {|f| f.write(auth.to_json)}
    auth
  end

  def get_new_access_tokens
    new_consumer = self.create_consumer
    new_request_token = self.request_token(consumer: new_consumer)
    new_authorize_url = self.get_authorize_url(request_token: new_request_token)
    authorize_new_application = self.authorize_application(authorize_url: new_authorize_url)
    extract_new_oauth_verifier = self.extract_oauth_verifier(callback_page: authorize_new_application)
    new_access_token = self.get_access_token(request_token: new_request_token, oauth_verifier: extract_new_oauth_verifier)
    save_tokens_to_json(filename: 'magento_oauth_access_tokens', path: '/', access_token: new_access_token)
    return 'Successfully obtained new access tokens.'
  end
end
