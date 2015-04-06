Feature: Cite and Email Bookmarks
  In order to cite and share my research
  As a researcher
  I would like to be able to bookmark records, cite and email them.


Scenario: Adding a bookmark
  Given I am a logged in user
  When I search on the phrase "Ben Alexrod"
  Then I should see search results 
  And each result should have a "Bookmark"
  When I check a bookmark
  Then my bookmarks count should be "1"
  #When I click on "Your Bookmarks"
  When I go to my bookmarks page
  


