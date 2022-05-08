# Squash

Squash is a simple url shortener program, like [bitly](https://bitly.com/). There is one API endpoint to create new shortened urls, `POST /newurl`.

Then n number of other endpoints to redirect shortened urls.

For full requirements, see [specs](spec.md).

## Prerequisites

* [terraform](https://www.terraform.io/downloads)
* [docker](https://docs.docker.com/get-docker/)
* [jq](https://stedolan.github.io/jq/download/)
* [packer]([https://www.packer.io/downloads)
* aws cli
* make

## Assumptions

The application assumes that it is being deployed into the us-east-1 region. Future improvements can be made to make everything a bit more agnostic to the AWS region.

## Building with Make

Make is used to tie everything together to make the deployment process easier. Normally I would use some CICD tool to tie everything together. But I felt make worked pretty well for this project.

Quickstart!

Before proceeding, make sure you have all the dependencies installed. And that your current AWS profile has the `us-east-1` region set.

```
make asg
```

This command will tie everything together. From building the docker image, to building an AWS AMI out of it, to deploying it into an ASG. To see the other options run `make help`.

## Infrastructure Design Considerations

Squash will be deployed into an AWS ASG, with some basic configurations to scale the instances based off of CPU Utilization. 

Squash will also use a Postgres server hosted by RDS, to store/retrieve records. AWS Parameter store is used to store environment based configurations. For now this mostly means the database hostname, databse  username, & hostname for the application endpoint.

The ASG will be sitting behind an Application load balancer. With the load balancer and ASG distributing load across 3 availability zones.

I think AWS CloudFront will be another big addition. I have not worked this integration in yet. Cloudfront can help take a lot of load from the application by serving cached responses from the CDN. This will help take off the load from the servers.

## Application Design Considerations

Since this application is fairly straight forward and speed is the name of the game, I used the (Gin Framework)[https://gin-gonic.com/]. I'm also leveraging a database migration tool called [Darwin](https://github.com/GuiaBolso/darwin) to automatically setup the database schema when the application connects to the database.

## Limitations

The biggest limitation right now is that all traffic must be processed by the application. Introducing a caching service like AWS Cloudfront can greatly increase availibility since it will take a lot of load off the application itself. It will also decrease response times for users around the world, since requests will get cached on edge locations closer to our users. 

Another limitation is that the application assumes that it is being deployed into us-east-1. This can be addressed as well. Minor programattic changes can be added to query the EC2 metadata to discover which region the application is running in at runtime. 

Improvements can most likely be made to for the ASG scaling rules. I have not yet stress tested the application. A tool such as [Vegeta](https://github.com/tsenart/vegeta) can be used to stress test the application to understand how the application will perform under heavy load, so we can make tweaks to the scaling policies.