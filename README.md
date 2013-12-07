# Multiple Languages in Jekyll

Jekyll Multiple Languages is an internationalization plugin for [Jekyll](https://github.com/mojombo/jekyll). It compiles your Jekyll site for one or more languages with a similar approach as Rails does. The different sites will be stored in sub folders with the same name as the language it contains.

The plugin is developed as an utility at [Screen Interaction](http://www.screeninteraction.com)

##Installation
Copy or link the file `multiple-languages-plugin.rb` into your `_plugins` folder
for your Jekyll project.

If your Jekyll project is in a git repository, you can easily
manage your plugins by utilizing git submodules.

To install this plugin as a git submodule:

    git submodule add git://github.com/screeninteraction/jekyll-multiple-languages-plugin.git _plugins/multiple-languages

To update:

    cd _plugins/multiple-languages
    git pull origin master
    
###Features
* Supports multiple languages with the same code base.
* Supports all template languages that your Liquid pipeline supports.
* Uses [Liquid tags](https://github.com/Shopify/liquid) in your HTML for including translated strings.
* Compiles the site multiple times for all supported languages into separate subfolders.
* The plugin even works with the -watch flag turned on and will rebuild all languages automatically.

##Usage
###Configuration
Add the i18n configuration to your _config.yml:

```yaml	
languages: ["sv", "en", "de", "fr"]
```

The first language in the array will be the default language, English, German and French will be added in to separate subfolders.

###i18n
Create this folder structure in your Jekyll project as an example:

    - /_i18/sv.yml
    - /_i18/en.yml
    - /_i18/de.yml
    - /_i18/fr.yml
    - /_i18/sv/pagename/blockname.md
    - /_i18/en/pagename/blockname.md
    - /_i18/de/pagename/blockname.md
    - /_i18/fr/pagename/blockname.md

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
	
So how can I add different translated titles to all pages? Don't worry, it's easy. The Multiple Languages plugin supports Liguid variables as well as strings so define a page variable in your page definition

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
		
##Linking between languages
This plugin gives you the variables
	
```liquid
{{ page.lang }}
	
and
	
{{ site.baseurl_root }}
```
	
to play with in your template files.

This allows you to create solutions like this:

```liquid
{% if site.lang == "sv" %}
	{% capture link1 %}{{ site.baseurl_root }}en{{ page.url}}{% endcapture %}
	<a href="{{ link1 }}" >{% t global.english %}</a>
{% else if site.lang == "en" %}
	{% capture link2 %}{{ site.baseurl_root }}{{ page.url | remove_first: '/'  }}{% endcapture %}
	<a href="{{ link2 }}" >{% t global.swedish %}</a>
{% endif %}
```
	
This code will add an `"English"` link in the Swedish pages and the other way around in the English pages.
