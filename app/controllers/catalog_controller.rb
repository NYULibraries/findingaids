# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController

  include Findingaids::Catman
  
  configure_blacklight do |config|
    config.default_solr_params = {
      :qt => "",
      :rows => 10,
      :qf => pf_fields,
      :pf => pf_fields,
      "hl.fragsize" => 0,
      ("hl.fl").to_sym => hl_fields,
      "hl.simple.pre" => "<span class=\"highlight\">",
      "hl.simple.post" => "</span>",
      "hl.requireFieldMatch" => true,
      "hl.usePhraseHighlighter" => true,
      :hl => true,
      :facet => true,
      "facet.mincount" => 1,
      :echoParams => "explicit",
      :ps => 50,
      :defType => "edismax"
    }
    
    config.default_document_solr_params = {
      :qt => "",
      ("hl.fl").to_sym => "title_ssm, author_ssm, publisher_ssm, collection_ssm,parent_unittitles_ssm,location_ssm",
      ("hl.simple.pre").to_sym => '<span class="label label-info">',
      ("hl.simple.post").to_sym => "</span>",
      :hl => true,
      :fl => "*",
      :rows => 1,
      :echoParams => "all",
      :q => "{!raw f=#{SolrDocument.unique_key} v=$id}"
    }

    # solr field configuration for search results/index views
    config.index.show_link = solr_name("heading", :displayable)
    config.index.record_display_type = solr_name("format", :displayable)

    # solr field configuration for document/show views
    config.show.html_title = solr_name("heading", :displayable)
    config.show.heading = solr_name("heading", :displayable)
    config.show.display_type = solr_name("format", :displayable)
    
    config.add_field_configuration_to_solr_request!

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Requestd handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    config.add_facet_field solr_name("format",     :facetable), :label => "Format",             :limit => 20
    config.add_facet_field solr_name("collection", :facetable), :label => "Collection Name",    :limit => 20
    #config.add_facet_field solr_name("material",   :facetable), :label => "Archival Material",  :limit => 20
    config.add_facet_field solr_name("name",       :facetable), :label => "Name",               :limit => 20
    config.add_facet_field solr_name("subject",    :facetable), :label => "Subject",            :limit => 20
    config.add_facet_field solr_name("genre",      :facetable), :label => "Genre",              :limit => 20    
    config.add_facet_field solr_name("series",     :facetable), :label => "Series",             :limit => 20
    config.add_facet_field solr_name("pub_date",   :facetable), :label => "Publication Date",   :limit => 20
    config.add_facet_field solr_name("language",   :facetable), :label => "Language",           :limit => true
    
    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!
    
    
    # ------------------------------------------------------------------------------------------
    #
    # Index view fields
    #
    # ------------------------------------------------------------------------------------------
    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name("title",             :displayable),  :label => "Title:", 
                                                                          :highlight => true,
                                                                          :helper_method => :render_highlighted_field
                                                                          
    config.add_index_field solr_name("abstract",          :displayable),  :label => "Abstract:", 
                                                                          :highlight => true,
                                                                          :helper_method => :render_highlighted_field
    
    config.add_index_field solr_name("format",            :displayable),  :label => "Format:",
                                                                          :helper_method => :render_field_name

    config.add_index_field solr_name("language",          :displayable),  :label => "Language:",
                                                                          :helper_method => :render_field_name
                                                                          
    config.add_index_field solr_name("publisher",         :displayable),  :label => "Publisher:",
                                                                          :helper_method => :render_field_name

    config.add_index_field solr_name("unitdate",          :displayable),  :label => "Dates:",
                                                                          :helper_method => :render_field_name

    config.add_index_field solr_name("collection",        :displayable),  :label => "Archival Collection:", 
                                                                          :helper_method => :render_collection_facet_link,
                                                                          :highlight => true
                                                                         
    config.add_index_field solr_name("parent_unittitles", :displayable),  :label => "Series:",
                                                                          :highlight => true,
                                                                          :helper_method => :render_series_facet_link

    config.add_index_field solr_name("location",          :displayable),  :label => "Location:",
                                                                          :highlight => true,
                                                                          :helper_method => :render_field_name
                                                                          
    # ------------------------------------------------------------------------------------------
    #
    # Show view fields (individual record)
    #
    # ------------------------------------------------------------------------------------------
    # solr fields to be displayed in the show (single result) view
    # The ordering of the field names is the order of the display
    # None of these fields apply to ead documents or components
   
    #config.add_show_field solr_name("collection",   :displayable),  :label         => "Archival Collection:", 
    #                                                                :helper_method => :render_facet_link,
    #                                                                :facet         => solr_name("collection", :facetable),
    #                                                                :highlight     => true
    


    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field "score desc, title_si asc, format_si asc",                   :label => "relevance"
    config.add_sort_field "date_filing_si desc, title_si asc, format_si asc",          :label => "date"
    config.add_sort_field "title_si asc, format_si asc",                               :label => "title"
    config.add_sort_field "series_si asc, box_filing_si asc",                          :label => "series"

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5
  
    ##
    # Add repository field query from config file
    YAML.load_file( File.join(Rails.root, "config", "repositories.yml") )["Catalog"]["repositories"].each do |coll|
      config.add_search_field(coll.last["display"],
        :label => coll.last["display"], 
        :solr_parameters => { :fq => "repository_ssi:#{(coll.last["admin_code"].present?) ? coll.last["admin_code"].to_s : '*'}" }
        )
    end
  end
  
end
