# Webhook Mentions

This is a small web app that sends [Webmentions](http://webmention.net) to any links in new/updated posts in a [Jekyll](https://jekyllrb.com)-powered [GitHub Pages](https://pages.github.com) site marked up with [Microformats 2 h-entry markup](http://microformats.org/wiki/microformats2#h-entry).

Deploy the app and then set up a webhook from your GitHub Pages repository to it and whenever a post is successfully pushed webmentions will be sent to any links.

Webmention is a technology developed by the [IndieWeb](https://indieweb.org) community.

## Deploy

I recommend running this on Heroku using the _Deploy to Heroku_ button. You can host it yourself but will need to define the environment variables below.

[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy??template=https://github.com/barryf/webhook-mentions)

Choose a name for your copy of the app, e.g. `barryf-webhook-mentions`. Make a note of this for later. You'll next need to define the following configuration:

- `ROOT_URL` - the root URL of your GitHub Pages site, e.g. `https://barryf.github.io`.
- `GITHUB_ACCESS_TOKEN` - a personal access token for your GitHub Pages site (see below for help).
- `GITHUB_USER`: your GitHub username, e.g. `barryf`.
- `GITHUB_REPO`: your GitHub Pages site repository name, e.g. `barryf.github.io`.

#### Personal access token

1. Generate a [new personal access token](https://github.com/settings/tokens/new) for your GitHub account.
2. Give it a description, e.g. `Webhook Mentions`.
3. Select the `public_repo` scope.
4. Click the green _Generate token_ button.
5. Copy the token on the following page and keep this value safe. When the page is closed you cannot view this token again.

## Set up a webhook

1. Visit your GitHub Pages repository settings page and select _Webhooks & services_.
2. Create a new webhook by clicking the _Add webhook_ button.
3. Complete the following fields:
    - **Payload URL:** the root of your endpoint on Heroku e.g. `https://barryf-webhook-mentions.herokuapp.com`
    - **Content type:** `application/json`
    - **Secret:** _Leave blank._
    - **Which events...?** select _Let me select individual events_ and then select _Page build_.
4. Finish by clicking the green _Add webhook_ button.

## Write a new post

Test the integration out by writing a test post with a link to my blog post at `https://barryfrost.com/2016/07/introducing-webhook-mentions` and pushing it to your GitHub Pages site. A few seconds later you should see the webmention appear below my post.

Don't forget your post layout will need [Microformats 2 h-entry markup](http://microformats.org/wiki/microformats2#h-entry) or the app will not find the link to my blog post.

If you have any problems please log an issue and I'll try to help debug.