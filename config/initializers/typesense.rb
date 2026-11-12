# Typesense connection. Configure with env vars:
#   TYPESENSE_API_KEY  (required)
#   TYPESENSE_HOST     (default: localhost)
#   TYPESENSE_PORT     (default: 8108)
#   TYPESENSE_PROTOCOL (default: http)
Rails.application.config.to_prepare do
  ItemSearch.client ||= Typesense::Client.new(
    nodes: [ {
      host: ENV.fetch("TYPESENSE_HOST", "localhost"),
      port: ENV.fetch("TYPESENSE_PORT", "8108").to_i,
      protocol: ENV.fetch("TYPESENSE_PROTOCOL", "http")
    } ],
    api_key: ENV.fetch("TYPESENSE_API_KEY", ""),
    connection_timeout_seconds: 2,
    num_retries: 1,
    log_level: Logger::WARN
  )
end
