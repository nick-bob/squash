# Squash

Squash is a simple url shortener program, like [bitly](https://bitly.com/). There is one API endpoint to create new shortened urls, `POST /newurl`.

Then n number of other endpoints to redirect shortened urls.

For full requirements, see [specs](spec.md).

## Prerequisites

* jq
* terraform
* packer
* aws cli
* docker

## How to Deploy infrastructure

```
make asg
```

## Design Considerations

In order to give users the best experience & to keep the application as highly available as possible, Squash will lean heavily on [AWS Cloudfront](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Introduction.html). The reason is twofold; since Cloudfront will cache static responses on edge locations, responses will be faster once Cloudfront caches the data. Additionally this will lessen the load on the backend servers as well, since the Cloudfront edge locations will be able to help serve the traffic.

[more to come...](infra/README.md)

## Running locally

See the [webserver readme](src/README.md) 
