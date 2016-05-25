# Jekyll Multiple Languages Plugin

Jekyll Multiple Languages is an internationalization plugin for [Jekyll](https://github.com/mojombo/jekyll). It compiles your Jekyll site for one or more languages with a similar approach as Rails does. The different sites will be stored in sub folders with the same name as the language it contains.

The plugin was developed as an utility at [Screen Interaction](http://www.screeninteraction.com)

### Gem [![Gem Version](https://badge.fury.io/rb/jekyll-multiple-languages-plugin.png)](http://badge.fury.io/rb/jekyll-multiple-languages-plugin)



## Current Relese Notice

1.4.1 is the current stable release.

Users that update from older versions to 1.4.0 or newer must change their `_config.yml` for the plugin to be loaded. Please see the `Installation` section bellow for the new string used to load the plugin.

The plugin now works with Jekyll 3, but it's backwards compatible with Jekyll 2.
Please note that it was only tested with Jekyll 2.5.3 and 3.1.3.

The support for Octopress is dropped, but the plugin still should work with it since Octopress core is Jekyll.
Octopress 3 now has it's own multi languages plugin: https://github.com/octopress/multilingual



## Features
* Works with Jekyll 2.5.3 and 3.1.3
* Supports multiple languages with the same code base.
* Supports all template languages that your Liquid pipeline supports.
* Uses [Liquid tags](https://github.com/Shopify/liquid) in your HTML for including translated strings.
* Compiles the site multiple times for all supported languages into separate subfolders.
* Works with the --watch flag turned on and will rebuild all languages automatically.
* Contains an example web site thanks to [@davrandom](https://github.com/davrandom/)
* Supports translated keys in YAML format
* Supports translated template files
* Supports translated links



## Installation

### Using the gem

This plugin is available as a Rubygem, https://rubygems.org/gems/jekyll-multiple-languages-plugin.

Add this line to your application's Gemfile:

```
gem 'jekyll-multiple-languages-plugin'
```

And then execute: `$ bundle install`

Or install it yourself as: `$ gem install jekyll-multiple-languages-plugin`

To activate the plugin add it to the Jekyll `_config.yml` file, under the `gems` option:

```ruby
gems: 
  - jekyll-multiple-languages-plugin
```
See the [Jekyll configuration documentation](http://jekyllrb.com/docs/configuration) for details.

### Manually
1. Download the repository with Git or your preferred method.
2. Inside your Jekyll `_plugins` folder create a new folder called `jekyll-multiple-languages-plugin`.
3. Copy or link the directory `lib`, that is inside the downloaded repository, into your `_plugins/jekyll-multiple-languages-plugin` folder of your Jekyll project.

### As a Git Submodule

If your Jekyll project is in a git repository, you can easily manage your plugins by utilizing git submodules.

To install this plugin as a git submodule:

```sh
$ git submodule add git://github.com/screeninteraction/jekyll-multiple-languages-plugin.git _plugins/multiple-languages
```

To update:

```sh
$ cd _plugins/multiple-languages
$ git pull origin master
```



## Configuration
### _config.yml
Add the languages available in your website into your _config.yml (obligatory):

```yaml
languages: ["sv", "en", "de", "fr"]
```

The first language in the array will be the default language, English, German and French will be added in to separate subfolders.

To avoid redundancy, it is possible to exclude files and folders from being copied to the localization folders.

```yaml
exclude_from_localizations: ["javascript", "images", "css"]
```
In code, these specific files should be referenced via `baseurl_root`. E.g.

```
<link rel="stylesheet" href="{{ "/css/bootstrap.css" | prepend: site.baseurl_root }}"/>
```

### Folder structure
Create a folder called `_i18n` and add sub-folders for each language, using the same names used on the `languages` setting on the `_config.yml`:

  - /_i18n/sv.yml
  - /_i18n/en.yml
  - /_i18n/de.yml
  - /_i18n/fr.yml
  - /_i18n/sv/pagename/blockname.md
  - /_i18n/en/pagename/blockname.md
  - /_i18n/de/pagename/blockname.md
  - /_i18n/fr/pagename/blockname.md



## Usage
### Translating strings
To add a translated string into your web page use one of these liquid tags:

```liquid
{% t key %}
or
{% translate key %}
```

This will pick the correct string from the `language.yml` file during compilation.

The language.yml files are written in YAML syntax which caters for a simple grouping of strings.

```yaml
global:
	swedish: Svenska
	english: English
pages:
	home: Home
	work: Work
```

  To access the english key, use one of these tag:

```liquid
{% t global.english %}
or
{% translate global.english %}
```

### Including translated files
The plugin also supports using different markdown files for different languages using the liquid tag:

```liquid
{% tf pagename/blockname.md %}
or
{% translate_file pagename/blockname.md %}
```

This plugin have exactly the same support and syntax as the Jekyll's built in liquid tag:

```liquid
{% include file %}
```

so plugins that extends its functionality should be picked up by this plugin as well.

### Permalinks and Translating Links
To use localized pages with permalinks, you must provide a defalt permalink `permalink` and the language specific permalinks, for example, `permalink_fr` for French.

To translate links, you must also add a **unique namespace** on the YAML front matter along with the permalinks.

Example:

```yaml
---
layout:         default

namespace:     team

permalink:      /team/
permalink_fr:   /equipe/
---
```

And then you can use the translate link liquid tag like this:

```liquid
<a href="{% tl team %}"> <!--This link will return /team if we are in the english version of the website and /fr/equipe if it's the french version</a>-->

<a href="{% tl team fr %}"> <!--This link will always return /fr/equipe</a>-->

or the longer version:

<a href="{% translate_link team %}"> <!--This link will return /team if we are in the english version of the website and /fr/equipe if it's the french version</a>-->

<a href="{% translate_link team fr %}"> <!--This link will always return /fr/equipe</a>-->
```

### i18n in templates
Sometimes it is convenient to add keys even in template files. This works in the exact same way as in ordinary files, however sometimes it can be useful to include different string in different pages even if they use the same template.

A perfect example is this:

```html
<html>
	<head>
		<title>{% t page.title %}</title>
	</head>
</html>
```

So how can I add different translated titles to all pages? Don't worry, it's easy. The Multiple Languages plugin supports Liquid variables as well as strings so define a page variable in your page definition

```yaml
---
layout: default
title: titles.home
---
```

and `<title>{% t page.title %}</title>` will pick up the `titles.home` key from `language.yml`

```yaml
titles:
	home: "Home"
```



### Link between languages
This plugin gives you the variables

```liquid
{{ page.lang }}

and

{{ site.baseurl_root }}
```

to play with in your template files.

This allows you to create solutions like this:


``` liquid
{% if site.lang == "sv" %}
  {% capture link1 %}{{ site.baseurl_root }}en{{ page.url}}{% endcapture %}
  <a href="{{ link1 }}" >{% t global.english %}</a>
{% elsif site.lang == "en" %}
  {% capture link2 %}{{ site.baseurl_root }}{{ page.url  }}{% endcapture %}
  <a href="{{ link2 }}" >{% t global.swedish %}</a>
{% endif %}
```

This snippet will create a link that will toggle between Swedish and English. A more detailed description of the variables used follows:

| Name              | Value                                                         | Example                    |
| ----------------: | :------------------------------------------------------------ | :------------------------- |
| site.lang         | The language used in the current compilation stage            | ``` en ```                 |
| site.baseurl      | Points to the root of the site including the current language | ``` http://foo.bar/en ```  |
| site.baseurl_root | Points to the root of the page without the language path      | ``` http://foo.bar ```     |
| page.url          | The current page's relative URL to the baseurl                | ``` /a/sub/folder/page/ ```|



### Creating pages
Depending on the theme, or your preferences, you need to create a "template" page at the root folder or in a folder (ex. `_pages`). Inside each page (in this example an `about.md`) you should have at least the following in the header and body:

```yaml
---
layout: page
title: About
permalink: /about/
---

{% translate_file about/about.md %}
```

Inside each of the language folders, you should create mirror pages to provide the actual content for that language (ex. `i18n/es/about/about.md`). Make sure to erase the headers from those md files, or else your site will break.



## Example website

This repository has an example website where you can test the plugin.
After downloading the repository, get into the `example` directory and run: `bundle install` to install the newest version of Jekyll (change the Gemfile to install another version), the plugin, and all other dependencies.

Then run `bundle exec jekyll serve` to start the Jekyll server. Using your web browser, access the address `http://localhost:4000`.

### Adding a new language

Imagine you want to add German pages on the test website. First, add a the new language into the list of languages on `_config.yml`:
```ruby
languages: ["it", "en", "es", "de"]
```

Create a new folder for the language under the `_i18n` folder and add a markdown file containing the translation, just like on the other languages folders, and you're done.

### Adding new page

Let's say you want to create an about page for the example website, you will create an `about.html` page on the root of the website (same place as index.html), with this:

```
---
layout: page
title: About
permalink: /about/
---

{% translate_file about/about.md %}
```

Then, create a file named `about.md` under `_i18n/en` with the English content. Repeat this for the other languages (_i18n/es/about.md ...). When running the website, visit the address `http://localhost:4000/about` to see the English version, `http://localhost:4000/es/about` for the Spanish one, etc.



## Changelog
* 1.4.1
  * Fixes a bug during site regeneration where translation paths were being nested based on wrongly set Jekyll variables.
* 1.4.0
  * Support for Jekyll 3, thanks to [@pedrocarmona](https://github.com/screeninteraction/jekyll-multiple-languages-plugin/pull/62)
  * How to create pages documentation, thanks to [@elotroalex](https://github.com/screeninteraction/jekyll-multiple-languages-plugin/pull/57)
  * Many bug fixes
  * Code refactoring, cleanup and reorganization
  * Files and folders reorganization
  * Improved and fixed issues on the example website
  * Inprovement and fixes on documentations
  * Inproved license files
* 1.3.0
  * Support for localized links and custom permalinks, thanks to [@jasonlemay](https://github.com/screeninteraction/jekyll-multiple-languages-plugin/pull/53)
  * Support for excluding posts from translation, thanks to [@ctruelson](https://github.com/screeninteraction/jekyll-multiple-languages-plugin/pull/51)
* 1.2.9
  * Bug fix when excluding files from translation, again thanks to [@h6](https://github.com/H6)
* 1.2.8
  * Support for excluding files from translation, thanks to [@h6](https://github.com/H6)
* 1.2.7
  * Support for Jekyll 2.5+, thanks to [@caxy4](https://github.com/caxy4)
* 1.2.6
  * Added fallback to default language, thanks to [@agramian](https://github.com/agramian)
* 1.2.5
  * Fixed a bug when global variables wasn't as global as expected
* 1.2.4
  * Fixed a bug when changes in .yml files got lost during live reload.
* 1.2.3
  * Much, much, much faster compilation when lots of translated strings.
* 1.2.2
  * Supports translated posts in Octopress
* 1.2.1
  * Supports writing translated posts in Jekyll
  * Supports translated .yml files in Octopress
* 1.2.0
  * Renamed the project to jekyll-multiple-languages-plugin
* 1.1.2
  * Support for both variables and strings in ```translate_file```
* 1.1.1
  * Fixed documentation
* 1.1.0
  * Pull request that removed dirty forward slash from URLs
* 1.0.0
  * First release


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Contributors
| User                                             | Contribution                         |
| :----------------------------------------------- | :----------------------------------- |
| [@pedrocarmona](https://github.com/pedrocarmona) | support for Jekyll 3                 |
| [@elotroalex](https://github.com/elotroalex)     | added a how to create page to README |
| [@mohamnag](https://github.com/mohamnag)         | permalink generation bug fix         |
| [@jasonlemay](https://github.com/jasonlemay)     | support for localized links          |
| [@ctruelson](https://github.com/ctruelson)       | support for excluding posts          |
| [@Bersch](https://github.com/bersch)             | better paths                         |
| [@Davrandom](https://github.com/davrandom)       | plugin usage example                 |
| [@agramian](https://github.com/agramian)         | fallback to default language         |
| [@h6](https://github.com/H6)                     | exclude files from translation       |
| [@leoditommaso](https://github.com/leoditommaso) | update the example page              |

### Created by
[@kurtsson](https://github.com/kurtsson) from [Screen Interaction](https://github.com/screeninteraction) (http://screeninteraction.com)


### Maintained by
- [@kurtsson](https://github.com/kurtsson)
- [@Anthony-Gaudino](https://github.com/Anthony-Gaudino)
