require 'xmlrpc/client'

class Service::Bugzilla < Service

  Title = 'Bugzilla'
  Description = 'Use this service to file tickets in bugzilla for new crash reports and in-app feedback.'

  string   :server_url, :product, :component, required: true
  string   :feedback_priority, :crash_report_priority, required: true, default: 'P4'
  string   :feedback_severity, :crash_report_severity, required: true, default: 'normal'
  boolean  :create_bug_for_crashes, default: true
  boolean  :create_bug_for_feedback, default: false

  string :user, required: true, sensitive: true
  password :password, required: true, sensitive: true

  def settings_test

    enterable_products = connection.call('Product.get', {
      ids: connection.call('Product.get_enterable_products')['ids']
    })['products']

    matching_product = enterable_products.find do |product|
      product['name'] == settings(:product)
    end

    return 'No matching product' unless matching_product

    product_id = matching_product['id']

    legal_versions   = connection.call('Bug.legal_values', {field: 'version',   product_id: product_id})['values']
    legal_components = connection.call('Bug.legal_values', {field: 'component', product_id: product_id})['values']
    legal_priorities = connection.call('Bug.legal_values', {field: 'priority',  product_id: product_id})['values']
    legal_severities = connection.call('Bug.legal_values', {field: 'severity',  product_id: product_id})['values']

    return 'No matching component' unless legal_components.include? settings(:component)
    return 'No matching crash priority' unless legal_priorities.include? settings(:crash_report_priority)
    return 'No matching crash severity' unless legal_severities.include? settings(:crash_report_severity)
    return 'No matching feedback priority' unless legal_priorities.include? settings(:feedback_priority)
    return 'No matching feedback severity' unless legal_severities.include? settings(:feedback_severity)

    'Success.'

  rescue RuntimeError => e
    e.message
  rescue OpenSSL::SSL::SSLError => e
    e.message
  rescue XMLRPC::FaultException => e
    e.message
  end

  def receive_crash_report
    if settings(:create_bug_for_crashes) == '1'
      connection.call 'Bug.create', {
        :product     => settings(:product),
        :component   => settings(:component),
        :summary     => simple(:message),
        :version     => simple(:version),
        :description => "A crash has been reported on #{simple :project} version #{simple :version}, [view it on AppBlade](#{url})",
        :priority    => settings(:crash_report_priority),
        :severity    => settings(:crash_report_severity)
      }
    end
    'Success.'
  end

  def receive_feedback
    if settings(:create_bug_for_feedback) == '1'
      connection.call 'Bug.create', {
        :product     => settings(:product),
        :component   => settings(:component),
        :summary     => simple(:message),
        :version     => simple(:version),
        :description => "#{simple :user} reported in-app feedback for #{simple :project} version #{simple :version}, [view it on AppBlade](#{url})\n\n#{simple :message}",
        :priority    => settings(:feedback_priority),
        :severity    => settings(:feedback_severity)
      }
    end
    'Success.'
  end

private

  def connection
    @connection ||= XMLRPC::Client.new2("#{settings(:server_url)}/xmlrpc.cgi").tap do |xmlrpc|
      xmlrpc.call 'User.login', {login: settings(:user), password: settings(:password)}
    end
  end

end
