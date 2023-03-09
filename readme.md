# Qwik Interval Static Regeneration (Qwik-ISR)

Qwik-ISR, not to be confused with [Next.js's ISR](https://nextjs.org/docs/basic-features/data-fetching/incremental-static-regeneration), is a build strategy that uses [Qwik's SSG adapter](https://qwik.builder.io/qwikcity/guides/static-site-generation/#static-site-generation-ssg-overview) to build [Qwik](https://qwik.builder.io/) web apps/sites on a predetermined interval. Qwik-ISR leverages Docker as a build/container tool, cron for scheduling and NGINX for statically serving the app.

The purpose of this build tool is to serve blazing fast Qwik apps 100% statically while still being able to update the content using a headless CMS.

## Usage

1. Copy `Dockerfile` and `nginx.conf` and place them in the root of your app/monorepo.
2. Run `docker build -t my-qwik-app --build-arg loc=exampleApp --build-arg cron="*/5 * * * *" .` (replace "exampleApp" with the path to your Qwik app)
3. After building start your container with `docker run --name my-qwik-app -p 8080:80 my-qwik-app`

You can use a tool like [crontab.guru](https://crontab.guru/#*/5_*_*_*_*) to select your build interval.

## The how

It's fairly simple but the details are important. The Qwik build script is scheduled in a cronjob however, while the app is building, Qwik mangles the `dist` directory. This means that for a short period of time between when the app is building, the website will be unavailable. Therefore a trick is utilized; before build, the `dist` folder is copied to a swap folder called `distSwp`. After that the NGINX symlink root is replaced from `/app/dist` to `/app/distSwp`. Following this seamless and instant swap, the app is safely built anew, once finished, the symlinked is swapped back to `/app/dist` and the cycle repeats.

## The why

As of now Qwik has plenty of SSR (server side rendering) options to dynamically render content on demand. However, it's not always this is a desireable due to higher server costs and slower page loads. Sites are commonly mostly static but still need to be updated from time to time an option is to then rebuild the website every time something needs to be updated. This is obviously very cumbersome and annoying, especially when the frequency of the updates is high and the administrator is not a developer. Therefore, by using a headless CMS, this tools allows you to keep all the benefits of SSG while also having a way to refresh the content on your page.

Furthermore, this build strategy only requires a very tiny server (only needing to run alpine linux and NGINX). Therefore it's trivial and cheap to scale to the edge or just use a standalone server. For example, you can easily use AWS's free tier to serve your site.
