Feature: Cite and Email Bookmarks
  In order to cite and share my research
  As a researcher
  I would like to be able to bookmark records, cite and email them.

@bm
Scenario: Clicking on "Bookmark" saves the bookmark
  Given I am a logged in user
  When I search on the phrase "Ben Alexrod"
  Then I should see search results 
  And each result should have a "Bookmark"
  When I check a bookmark
  #Then my "Your Bookmarks" count should increase by "1"
  


