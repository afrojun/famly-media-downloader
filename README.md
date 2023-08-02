# Famly Media Downloader

This tool fetches photos via the Famly API to allow preserving of higher resolution versions of the photos that are shared via the app. 

**_It does not allow access to any data that is not already accessible by the authenticated user and is intended solely for personal archival use._**

## Overview

At a high level this script has 5 steps:

1. Query Famly's feed API to gather a list of Observation IDs. Observations are the entities which contain references to images and videos.
2. Use the Observation IDs to query the GraphQL API which contains details of each Observation.
3. Gather details of each media file we need to download. Each Observation may contain all of the following types of media files along with the details to download them:
    - N Images
    - 1 Video
    - 1 File (unhandled)
4. Download the identified media files
5. Finally, we post-process the images and videos to ensure that they have their creation time set correctly so they are sorted in the right order when imported to photo libraries. A future enhancement to this could also set the geolocation to be that of the nursery.

For more details on this process see the [implementation notes](docs/implementation_notes.md).

## Setup

### Prerequisites

#### Ruby

I prefer to manage Ruby versions using [asdf](https://asdf-vm.com/), but you can also use `rbenv` if you prefer. Install Ruby 3.2.2 then install all dependencies using `bundler`.

#### SQLIte

The script uses [SQLite](https://www.sqlite.org/index.html) to keep track of which files have been downloaded and processed to avoid duplicate downloads and allow the script to be run multiple times safely.

SQLite is available for most platforms, the command below will install it on Mac 

```shell
brew install sqlite
```

#### EXIF Tool

This script updates image and video EXIF data to set the date they were created to the date of the Observation to ensure they are sorted appropriately in photo library managers like Google Photos and iPhoto. It does this using [EXIFTool](https://exiftool.org/) which has installers for most platforms. 

To install it on a Mac run:

```shell
brew install exiftool
```

### Get a token for API access

Log in to the app in a browser and open the developer tools (Inspector). On the "Network" tab, filter for `graphql` API requests and look at the request headers. Find the one named `x-famly-accesstoken` and copy the value. 

Create a new file `.env.local` in the root directory of the project and set `FAMLY_ACCESS_TOKEN` to the value you got above. This will allow the script to access the API. 

For example:

```shell
echo 'FAMLY_ACCESS_TOKEN=your-famly-access-token' > .env.local
```

### Initialise the SQLite DB

The script uses a SQLite DB to store data fetched from the API and record progress. Create and setup the local SQLite DB by running:

```shell
bundle exec sequel -m db/migrations sqlite://famly_media_downloader.db
```

### Download media

Run the script to start downloading all media that has been shared with you:

```shell
bin/run
```

## Testing

Create a test SQLite DB:

```shell
bundle exec sequel -m db/migrations sqlite://famly_media_downloader_test.db
```


Run the tests using RSpec:

```shell
bundle exec rspec
```

## Dump the GraphQL schema

This should not be necessary but if something breaks in future we can update the cached GraphQL schema using this command:

```shell
bin/dump_schema
```
