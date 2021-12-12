# Famly API

This tool fetches photos via the Famly API to allow preserving of higher resolution versions of the photos that are shared via the app. It does not allow access to any data that is not already accessible by the authenticated user.

## Notes

BASE_URL = https://app.famly.co

### GET /api/feed/feed/feed

https://app.famly.co/api/feed/feed/feed?olderThan=2021-09-08T15%3A58%3A43%2B00%3A00
https://app.famly.co/api/feed/feed/feed?olderThan=${URL encoded timestamp}

- Paginated RESTful API
- Returns up to 10 responses

feedItems -> embed (can be null) -> observationId
feedItems -> createdDate (for next page)

### POST /graphql

#### childDevelopment

Cannot query by childIds or institutionIds - API returns an error
Only observationIds works, so need to combine with feed API
Can ignore variant: "PARENT_OBSERVATION"

```graphql
query ObservationsByIds($observationIds: [ObservationId!]!) {
  childDevelopment {
    observations(
      first: 100
      observationIds: $observationIds
      ignoreMissing: true
    ) {
      results {
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
```

### Process

#### Done

- Query feed API with current time
- Get the embedded observationIds if present

#### TODO

- Query childDevelopment GraphQL API with those IDs
- Store raw information on images, videos and files in local files
- Image URL: {images.secret.prefix}/{images.secret.key}/2560x2560/{images.secret.path}?expires={images.secret.expires}
- Video URL: {video.videoUrl}
- File URL: {file.url}
