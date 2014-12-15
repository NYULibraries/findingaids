require 'solr_ead'
require 'fileutils'

class Findingaids::Ead::Indexer

  def self.delete_all
    Blacklight.solr.delete_by_query("*:*")
    Blacklight.solr.commit
  end

  attr_accessor :indexer, :data_path

  def initialize(data_path="data")
    @data_path = data_path
    @indexer = SolrEad::Indexer.new(document: Findingaids::Ead::Document, component: Findingaids::Ead::Component)
  end

  def index(file)
    if file.blank?
      raise ArgumentError.new("Expecting #{file} to be a file or directory")
    end
    unless File.directory?(file)
      update(file)
    else
      Dir.glob(File.join(file,"*")).each do |file|
        update(file)
      end
    end
  end

  def reindex_changed
    changed_files.each do |file|
      status, filename = file.split("\t")
      fullpath = File.join(data_path, filename)
      update_or_delete(fullpath)
    end
  end

private

  # Get the sha for the last commit
  def last_commit
    @last_commit ||= `cd #{data_path} && git log --pretty=format:'%h' -1 && cd ..`
  end

  # Get list of files changed since last commit
  def changed_files
    @changed_files ||= (`cd #{data_path} && git diff-tree --no-commit-id --name-status -r #{last_commit} && cd ..`).split("\n")
  end

  # Update or delete depending on git status
  def update_or_delete(file)
    if File.exists?(file)
      update(file)
    # Status == D means the file was deleted
    elsif status.eql? "D"
      delete(file)
    end
  end

  # Wrapper method for SolrEad::Indexer#update(file)
  # => @file      filename of EAD
  def update(file)
    if file.blank?
      raise ArgumentError.new("Expecting #{file} to be a file or directory")
    end
    begin
      indexer.update(file)
      log.info "Indexed #{File.basename(file)}."
    rescue Exception => e
      log.info "Failed to index #{File.basename(file)}: #{e}."
      false
    end
  end

  # Wrapper method for SolrEad::Indexer#delete
  # => @id        EAD id
  def delete(file)
    if file.blank?
      raise ArgumentError.new("Expecting #{file} to be a file or directory")
    end
    id = File.basename(file).split("\.")[0]
    begin
      delete(id)
      log.info "Deleted #{File.basename(file)} with id #{id}."
    rescue Exception => e
      log.info "Failed to delete #{File.basename(file)} with id #{id}: #{e}"
      false
    end
  end

  # Set FINDINGAIDS_LOGGER=STDOUT to view logs in standard out
  def log
    @log ||= (ENV['FINDINGAIDS_LOG']) ? Logger.new(ENV['FINDINGAIDS_LOG'].constantize) : Rails.logger
  end
end
