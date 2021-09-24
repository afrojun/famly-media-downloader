# frozen_string_literal: true

module Famly
  module GraphQL
    module Queries
      module ObservationsByIds
        Query = Client.parse <<-'GRAPHQL'
          query ObservationsByIds($observationIds: [ObservationId!]!) {
            childDevelopment {
              observations(
                first: 100
                observationIds: $observationIds
                ignoreMissing: true
              ) {
                results {
                  id
                  createdBy {
                    name {
                      fullName
                    }
                  }
                  files {
                    name
                    url
                    id
                  }
                  images {
                    height
                    width
                    id
                    secret {
                      crop
                      expires
                      key
                      path
                      prefix
                    }
                  }
                  video {
                    ... on TranscodingVideo {
                      id
                    }
                    ... on TranscodedVideo {
                      duration
                      height
                      id
                      thumbnailUrl
                      videoUrl
                      width
                    }
                  }
                  variant
                }
              }
            }
          }
        GRAPHQL
      end
    end
  end
end
