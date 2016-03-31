class MessageController < ApplicationController
  include RailsLti2Provider::ControllerHelpers

  skip_before_action :verify_authenticity_token
  before_filter :lti_authentication, except: :youtube

  rescue_from RailsLti2Provider::LtiLaunch::Unauthorized do |ex|
    @error = 'Authentication failed with: ' + case ex.error
                                                when :invalid_signature
                                                  'The OAuth Signature was Invalid'
                                                when :invalid_nonce
                                                  'The nonce has already been used'
                                                when :request_to_old
                                                  'The request is to old'
                                                else
                                                  'Unknown Error'
                                              end
    @message = IMS::LTI::Models::Messages::Message.generate(request.request_parameters.merge(request.query_parameters))
    @header = SimpleOAuth::Header.new(:post, request.url, @message.post_params, consumer_key: @message.oauth_consumer_key, consumer_secret: 'secret', callback: 'about:blank')
    render :basic_lti_launch_request, status: 200
  end

  def basic_lti_launch_request
    # process_message
    @tp = {"outcome_service"=>false, "params"=>{"problem_url"=>"PL2in", "short_name"=>"Intro", "gradeable_exercise"=>"", "section_name"=>"00.01.01 - How to Use this System", "problem_type"=>"module", "JOP-lang"=>"", "JXOP-feedback"=>"", "JXOP-fixmode"=>"", "JXOP-code"=>"", "JXOP-debug"=>"", "threshold"=>""}, "to_params"=>{"context_id"=>"a8d0c7bc626898a9e2a97667c22b40754051cc41", "context_label"=>"PL2", "context_title"=>"Programming Languages: Book 2", "launch_presentation_document_target"=>"iframe", "launch_presentation_locale"=>"en", "launch_presentation_return_url"=>"https://canvas.instructure.com/courses/1004654/external_content/success/external_tool_redirect", "lis_person_contact_email_primary"=>"hshahin@cs.vt.edu", "lis_person_name_family"=>"Shahin", "lis_person_name_full"=>"Hossameldin Shahin", "lis_person_name_given"=>"Hossameldin", "lti_message_type"=>"basic-lti-launch-request", "lti_version"=>"LTI-1p0", "oauth_callback"=>"about:blank", "oauth_consumer_key"=>"test", "oauth_nonce"=>"UQE8WunWZWhK39OUlQrRTbYZzMx4nKkrOgGT0qu8Y", "oauth_signature"=>"xS96wFtfrZjU8cZAYnrfjsZOwYA=", "oauth_signature_method"=>"HMAC-SHA1", "oauth_timestamp"=>"1459386809", "oauth_version"=>"1.0", "resource_link_id"=>"deb0f5ed9fa5b2639a702a71bc35fb5262677a80", "resource_link_title"=>"00.01.01 - How to Use this System", "roles"=>"instructor", "tool_consumer_info_product_family_code"=>"canvas", "tool_consumer_info_version"=>"cloud", "tool_consumer_instance_contact_email"=>"notifications@instructure.com", "tool_consumer_instance_guid"=>"07adb3e60637ff02d9ea11c7c74f1ca921699bd7.canvas.instructure.com", "tool_consumer_instance_name"=>"Free For Teachers", "user_id"=>"ba828352783e674029e8817a0e87eb3232f96e53", "user_image"=>"https://secure.gravatar.com/avatar/036f7ecf8f9e98c2c5f3fe59a419a580?s=50&d=https%3A%2F%2Fcanvas.instructure.com%2Fimages%2Fmessages%2Favatar-50.png", "custom_canvas_api_domain"=>"canvas.instructure.com", "custom_canvas_course_id"=>"1004654", "custom_canvas_enrollment_state"=>"active", "custom_canvas_user_id"=>"4525025", "custom_canvas_user_login_id"=>"hshahin@cs.vt.edu", "ext_roles"=>"urn:lti:instrole:ims/lis/Instructor,urn:lti:role:ims/lis/Instructor,urn:lti:sysrole:ims/lis/User"}}

    puts @tp

    @section_html = read_html
    # render :template => 'public/OpenDSA/Books/testLTI/lti_html/ADT-01.html'
    # render :file=>'console/users/show.html.erb', :locals => {:@user => @users.first}
    # render :file=>'console/users/show.html.erb', :locals => {:user => @users.first}

    # @user = @users.first
    # render :file=>'console/users/show.html.erb'
    # render(:partial => 'public/OpenDSA/Books/testLTI/lti_html/ADT-01.html', locals: { :tp => @tp })

  end

  def content_item_selection
    process_message
  end

  def youtube
    redirect_to params[:youtube_url]
  end

  private

  def process_message
    @secret = "&#{RailsLti2Provider::Tool.find(@lti_launch.tool_id).shared_secret}"
    #TODO: should we create the lti_launch with all of the oauth params as well?
    @message = (@lti_launch && @lti_launch.message) || IMS::LTI::Models::Messages::Message.generate(request.request_parameters.merge(request.query_parameters))
    @header = SimpleOAuth::Header.new(:post, request.url, @message.post_params, consumer_key: @message.oauth_consumer_key, consumer_secret: 'secret', callback: 'about:blank')
  end

  private

  def read_html()
    File.read('public/OpenDSA/Books/testLTI/lti_html/ADT-01.html')
end

end