Paperclip::Attachment.default_options[:storage] = :s3
Paperclip::Attachment.default_options[:s3_credentials] = {:bucket => "bmrng-#{Rails.env}",
                                                          :access_key_id => ENV['amazon_access_key_id'],
                                                          :secret_access_key => ENV['amazon_secret_access_key']}
Paperclip::Attachment.default_options[:s3_protocol] = 'http'
Paperclip::Attachment.default_options[:url] = ':s3_domain_url'
Paperclip::Attachment.default_options[:path] = '/:class/:attachment/:id_partition/:style/:filename'
