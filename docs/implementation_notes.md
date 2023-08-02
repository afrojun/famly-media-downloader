# Implementation Notes

As described in the [Readme](../README.md#Overview), this script has 5 steps. Here's a bit more context on the steps and how it works.

## Feed API

- A paginated, RESTful API
- Returns up to 10 responses per page
- Pass the `olderThan` query param to fetch feed items before the given timestamp.


### GET /api/feed/feed/feed

```
https://app.famly.co/api/feed/feed/feed?olderThan=${URL encoded timestamp}

E.g. https://app.famly.co/api/feed/feed/feed?olderThan=2021-09-08T15%3A58%3A43%2B00%3A00
```

The response is large, but the fields we're interested in are the `observationId` and `createdDate`:

```json
{
  "feedItems": [
    {
      "embed": { "observationId": "obs1-id" },
      "createdDate": "2023-07-30T12:36:27+00:00"
    },
    {
      "embed": {},
      "createdDate": "2023-07-29T07:16:37+00:00"
    }
  ]
}
```

Note that `embed` can be an empty object in which case that feed item does not have an associated observation. We use `createdDate` to fetch the next page by passing it as the `olderThan` query param to the API.

## GraphQL API

Once we have observation IDs we fetch details of those observations via the `childDevelopment` field from the GraphQL API.

### POST /graphql

#### childDevelopment

This API supports querying by `institutionIds`, `childIds` or `observationIds` but on `observationIds` seems to work, which is why we need to combine with the Feed API to get those IDs. 

We fetch data in batches of 100 at a time.

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

## Download

Based on the raw data returned from the GraphQL query we can build our media files. Files and Videos have direct download URLs, but Images need download URLs to be constructed out of the embedded `secret` data:

- Image URL: `{image.secret.prefix}/{image.secret.key}/2560x2560/{image.secret.path}?expires={image.secret.expires}`
- Video URL: `{video.videoUrl}`
- File URL: `{file.url}`
