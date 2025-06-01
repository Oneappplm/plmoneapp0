module Api
  class Base < Grape::API
    format :json
    prefix :api

    mount Api::V1::Base

    add_swagger_documentation(
      api_version: 'v1',
      hide_format: true,
      hide_documentation_path: false,
      mount_path: '/swagger_doc',
      info: {
        title: 'PLMHealth Resource API',
        description: "Welcome to the PLMHealth API documentation.\n\n" \
                     "## Getting Started\n\n" \
                     "All endpoints are under `/api/v1`.\n\n" \
                     "## Authentication\n\n" \
                     "Every request must include an API key in the header:\n\n" \
                     "```\nX-Api-Key: your-api-key-here\n```\n\n" \
                     "Unauthorized requests will receive a `401 Unauthorized` response.\n\n" \
                     "## Support\n\n" \
                     "For questions, contact [admin@plmhealthoneapp.com](mailto:admin@plmhealthoneapp.com).",
        contact_name: 'PLMHealth Admin',
        contact_email: 'admin@plmhealthoneapp.com'
      },
      security_definitions: {
        api_key: {
          type: 'apiKey',
          name: 'X-Api-Key',
          in: 'header'
        }
      },
      security: [{ api_key: [] }]
    )
  end
end
