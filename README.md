# Multiple Languages in Jekyll

Jekyll Multiple Languages is an internationalization plugin for [Jekyll](https://github.com/mojombo/jekyll). It compiles your Jekyll site for one or more languages with a similar approach as Rails does. The different sites will be stored in sub folders with the same name as the language it contains. Version 1.2.1 and later also supports Octopress.

The plugin is developed as an utility at [Screen Interaction](http://www.screeninteraction.com)

##Installation

### Gem [![Gem Version](https://badge.fury.io/rb/jekyll-multiple-languages-plugin.png)](http://badge.fury.io/rb/jekyll-multiple-languages-plugin)

This plugin is available as a Rubygem, https://rubygems.org/gems/jekyll-multiple-languages-plugin.

Add this line to your application's Gemfile:

```
gem 'jekyll-multiple-languages-plugin'
```

And then execute: `$ bundle`

Or install it yourself as: `$ gem install jekyll-multiple-languages-plugin`

To activate the plugin add this line in to a *.rb file in the _plugins directory:

```ruby
require 'jekyll/multiple/languages/plugin'
```


### Submodule
If your Jekyll project is in a git repository, you can easily
manage your plugins by utilizing git submodules.

To install this plugin as a git submodule:

```sh
$ git submodule add git://github.com/screeninteraction/jekyll-multiple-languages-plugin.git _plugins/multiple-languages
```

To update:

```sh
$ cd _plugins/multiple-languages
$ git pull origin master
```


### Copy file
Copy or link the file `lib/jekyll/multiple/languages/plugin.rb` into your `_plugins` folder for your Jekyll project.


##Features
* Supports multiple languages with the same code base.
* Supports all template languages that your Liquid pipeline supports.
* Uses [Liquid tags](https://github.com/Shopify/liquid) in your HTML for including translated strings.
* Compiles the site multiple times for all supported languages into separate subfolders.
* The plugin even works with the -watch flag turned on and will rebuild all languages automatically.
* Contains an example web site thanks to [@davrandom](https://github.com/davrandom/)
* Supports translated keys in YAML format
* Supports translated template files


##Usage
###Configuration
Add the i18n configuration to your _config.yml:

```yaml
languages: ["sv", "en", "de", "fr"]
```

The first language in the array will be the default language, English, German and French will be added in to separate subfolders.

To avoid redundancy, it is possible to exclude files and folders from beeing copied to the localization folders.

```yaml
exclude_from_localizations: ["javascript", "images", "css"]
```
In code these specific files should be referenced via `baseurl_root`. E.g.

```
<link rel="stylesheet" href="{{ "/css/bootstrap.css" | prepend: site.baseurl_root }}"/>
```

###i18n
Create this folder structure in your Jekyll project as an example:

  - /_i18n/sv.yml
  - /_i18n/en.yml
  - /_i18n/de.yml
  - /_i18n/fr.yml
  - /_i18n/sv/pagename/blockname.md
  - /_i18n/en/pagename/blockname.md
  - /_i18n/de/pagename/blockname.md
  - /_i18n/fr/pagename/blockname.md

To add a string to your site use one of these

```liquid
{% t key %}
or
{% translate key %}
```

Liquid tags. This will pick the correct string from the `language.yml` file during compilation.

The language.yml files are written in YAML syntax which caters for a simple grouping of strings.

```yaml
global:
	swedish: Svenska
	english: English
pages:
	home: Home
	work: Work
```

  To access the english key, use this tag:

```liquid
{% t global.english %}
or
{% translate global.english %}
```

The plugin also supports using different markdown files for different languages using the

```liquid
{% tf pagename/blockname.md %}
or
{% translate_file pagename/blockname.md %}
```

This plugin have exactly the same support and syntax as the built in

```liquid
{% include file %}
```

tag, so plugins that extends its functionality should be picked up by this plugin as well.

###i18n in templates
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

##Link between languages
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
  {% else if site.lang == "en" %}
    {% capture link2 %}{{ site.baseurl_root }}{{ page.url  }}{% endcapture %}
    <a href="{{ link2 }}" >{% t global.swedish %}</a>
  {% endif %}
```

This snippet will create a link that will toggle between Swedish and English. A more detailed description of the variables used follows:

| Name | Value | Example |
| ---: | :--- | :--- |
| site.lang | The language used in the current compilation stage | ``` en ``` |
| site.baseurl | Points to the root of the site including the current language | ``` http://foo.bar/en ``` |
| site.baseurl_root | Points to the root of the page without the language path | ``` http://foo.bar ``` |
| page.url | The current page's relative URL to the baseurl | ``` /a/sub/folder/page/ ```|


##Changelog
* 1.3.0
  * Support for localized links and custom permalinks, thanks to [@jasonlemay](https://github.com/screeninteraction/jekyll-multiple-languages-plugin/pull/53)
  * Support for excluding posts from translation, thanks to [ctruelson](https://github.com/screeninteraction/jekyll-multiple-languages-plugin/pull/51)
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
- [@Bersch](https://github.com/bersch), better paths
- [@Davrandom](https://github.com/davrandom), plugin usage example
- [@agramian](https://github.com/agramian), fallback to default language
- [@h6](https://github.com/H6), exclude files from translation
- [@leoditommaso](https://github.com/leoditommaso), update the example page
