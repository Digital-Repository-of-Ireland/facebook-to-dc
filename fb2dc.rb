require 'nokogiri'
require 'yaml'

# get args
if (ARGV.empty? || ARGV.size < 2)
    puts "USAGE: ruby fb2dc.rb <input file> <output dir>"
    exit 1
end

infile = ARGV[0]
outdir = ARGV[1]

if !File.file?(infile)
    puts "Could not find input file #{infile}"
    exit 2
end

if !File.directory?(outdir)
    puts "#{outdir} should be a directory"
    exit 3
end

# create the data and metadata subdirs
Dir.mkdir "#{outdir}/data" unless File.directory?("#{outdir}/data")
Dir.mkdir "#{outdir}/metadata" unless File.directory?("#{outdir}/metadata")

# read the FB timeline export data, if this is really big I guess it could bork
data = File.read(infile)
doc = Nokogiri::HTML(data)

# read the default dc fields from the config file
settings_file = File.file?('conf/settings.local.yml')? "conf/settings.local.yml" : "conf/settings.yml"
Settings = YAML.load_file(settings_file)

doc.css('div[class=comment]').each do |div|
    # Each comment has a date in the previous sibling div
    date = div.previous_element.text

    # The post datestamps will probably be unique, we will use them as the object file basename
    basename = date.gsub(/\s/, '')

    # Now format the date in a nicer way
    w3c_date = Date.parse(date).strftime('%Y-%m-%d')

    # The asset text is the comment body
    body = div.text

    # Take the first line of the comment as the title
    # do a little bit of cleanup to remove odd chars
    delimiters = [',', /\n/, ":", ";", ".", /\r/]
    tmp = body.split(Regexp.union(delimiters)).reject { |l| l.empty? }
    title = tmp[0]
    title.gsub!(/^\"/, '')
    title.gsub!(/^''/, '')
    title.gsub!(/”/, '')
    title.gsub!(/“/, '')
    title.gsub!(/^\s/, '')
    title.gsub!(/‘/, '')

    # Output to asset file
    File.open("#{outdir}/data/#{basename}.txt", "w") do |f|     
        f.write(body)   
    end
   
    # Create XML QDC doc
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.qualifieddc('xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
                      'xmlns:dcterms' => 'http://purl.org/dc/terms/',
                      'xmlns:marcrel' => 'http://www.loc.gov/marc.relators/',
                      'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                      'xsi:schemaLocation' => 'http://www.loc.gov/marc.relators/ http://imlsdcc2.grainger.illinois.edu/registry/marcrel.xsd',
                      'xsi:noNamespaceSchemaLocation' => 'http://dublincore.org/schemas/xmls/qdc/2008/02/11/qualifieddc.xsd') {

                            # these fields will come from the FB timeline export
                            xml['dc'].title title
                            xml['dcterms'].issued w3c_date

                            # the rest of the DC fields will be the same for all objects and come from the settings file
                            # This is not a loop as for some fields we might have special requirements
                            # e.g. some fields might be pupulated from several sources

                            # CREATOR
                            if Settings['fields'].has_key?('creator') 
                                Settings['fields']['creator'].each do |creator|
                                    xml['dc'].creator creator
                                end
                            end

                            # CONTRIBUTOR
                            if Settings['fields'].has_key?('contributor')
                                Settings['fields']['contributor'].each do |contributor|
                                    xml['dc'].contributor contributor
                                end
                            end

                            # PUBLISHER
                            if Settings['fields'].has_key?('publisher')
                                Settings['fields']['publisher'].each do |publisher|
                                    xml['dc'].publisher publisher
                                end
                            end

                            # DATE
                            if Settings['fields'].has_key?('date')
                                Settings['fields']['date'].each do |date|
                                    xml['dc'].date date 
                                end
                            end

                            # TITLE
                            if Settings['fields'].has_key?('title')
                                Settings['fields']['title'].each do |title|
                                    xml['dc'].title title
                                end
                            end

                            # SUBJECT
                            if Settings['fields'].has_key?('subject')
                                Settings['fields']['subject'].each do |subject|
                                    xml['dc'].subject subject
                                end
                            end

                            # DESCRIPTION
                            if Settings['fields'].has_key?('description')
                                Settings['fields']['description'].each do |description|
                                    xml['dc'].description description
                                end
                            end

                            # TYPE
                            if Settings['fields'].has_key?('type')
                                Settings['fields']['type'].each do |type|
                                    xml['dc'].type type
                                end
                            end

                            # FORMAT
                            if Settings['fields'].has_key?('format')
                                Settings['fields']['format'].each do |format|
                                    xml['dc'].format format
                                end
                            end

                            # IDENTIFIER
                            if Settings['fields'].has_key?('identifier')
                                Settings['fields']['identifier'].each do |identifier|
                                    xml['dc'].identifier identifier
                                end
                            end

                            # SOURCE 
                            if Settings['fields'].has_key?('source')
                                Settings['fields']['source'].each do |source|
                                    xml['dc'].source source
                                end
                            end

                            # LANGUAGE
                            if Settings['fields'].has_key?('language')
                                Settings['fields']['language'].each do |language|
                                    xml['dc'].language language
                                end
                            end

                            # RELATiON
                            if Settings['fields'].has_key?('relation')
                                Settings['fields']['relation'].each do |relation|
                                    xml['dc'].relation relation
                                end
                            end

                            # COVERAGE
                            if Settings['fields'].has_key?('coverage')
                                Settings['fields']['coverage'].each do |coverage|
                                    xml['dc'].coverage coverage
                                end
                            end

                            # RIGHTS
                            if Settings['fields'].has_key?('rights')
                                Settings['fields']['rights'].each do |rights|
                                    xml['dc'].rights rights
                                end
                            end

                            if Settings['fields'].has_key?('temporal')
                                Settings['fields']['temporal'].each do |temporal|
                                    xml['dcterms'].temporal temporal
                                end
                            end

                            if Settings['fields'].has_key?('spatial')
                                Settings['fields']['spatial'].each do |spatial|
                                    xml['dcterms'].spatial spatial
                                end
                            end

      }
    end

    # Output to metadata file
    File.open("#{outdir}/metadata/#{basename}.xml", "w") do |f|
        f.write(builder.to_xml)                  
    end
end

