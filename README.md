# Famly Media Downloader

This tool fetches photos via the Famly API to allow preserving of higher resolution versions of the photos that are shared via the app. It does not allow access to any data that is not already accessible by the authenticated user and is intended solely for personal archival use.

## Install Ruby

I prefer to manage Ruby versions using `asdf`, but you can also use `rbenv` if you prefer. We are currently using Ruby 3.2.2.

## Set up API access

Log in to the app in a browser and open the developer tools (Inspector). On the "Network" tab, filter for `graphql` API requests and look at the request headers. Find the one named `x-famly-accesstoken` and copy the value. Set `FAMLY_ACCESS_TOKEN` in your shell to allow the script to access the API. For example:

```
export FAMLY_ACCESS_TOKEN=de5be9ea-bf5b-4db5-802d-11681eae3cd0
```

## Set up the local SQLite DB

Create and setup the local SQLite DB by running:

```
bin/migrate
```

## Download media

Run the script to start downloading all media that has been shared with you.

```
bin/run
```

## Dump the GraphQL schema

This should not be necessary but if something breaks in future update the cached GraphQL schema:

```
bin/dump_schema
```

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
