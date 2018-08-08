# facebook-to-dc
Tool for converting posts from an exported html Facebook Timeline to Dublin Core.
The tool was written for the purpose of creating XML DC metadata for batch ingest into the Digital Repository of Ireland. The metadata output should be suitable for ingest into other systems too.

It can be used mostly as is, but depending on your metadata needs you might want to modify the script a bit, e.g. you night want to make the dc:description field contain a generic description from the settings file, plus the title and date extracted from the Facebook Timeline export file. This would require some small code tweaks as details such as this will be different for each collection and I haven't bothered to make this configurable yet. 

It is very unlikely that this will produce perfect metadata and some curation and review will almost certainly be required.

This script is not a replacement for a qualified cataloguer!

# Installation
Clone the repository from Github. Open a terminal or command line prompt and navigate to the directory where you cloned the repository. To install the required Ruby Gems run

$ bundle install

# Configuration
Modify the conf/settings.yml (or create conf/settings.local.yml) file to include the generic dc values that you want included in every object. In addition to these generic fields, the html export file of the Facebook timeline will be parsed. The body of each comment will become a text asset in the output data directory. The first line of the body will become a dc:title, and the post date will become a dc:date field. The metadata xml file will be saved to the output metadata directory.

Filenames will use the post date. Metadata will have the extension .xml while the text assets will have the extension .txt

# Running
$ ruby fb2dc.rb \<input file> \<output dir>

Input file is the index.html from the Facebook timeline export.

output dir is a location where the metadata and text assets will be saved.
