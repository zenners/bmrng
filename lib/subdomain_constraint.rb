class SubdomainConstraint
  def initialize(subdomains)
    @subdomains = [subdomains].flatten
  end

  def matches?(request)
    request.subdomain.split('.').map{|sd|
      @subdomains.include?(sd) ? true : false}.include?(true)
  end
end