@api
Feature: Themes API
  Scenario: List all themes
    Given 3 themes
    When I GET "/api/themes"
    Then the response status should be 200
    And  the response should contain 3 themes

  Scenario: Create a new theme
    When I POST "/api/themes":
      """
      {
        "theme": {
          "name": "A theme name!",
          "description": "A beautiful theme",
          "body": "{{landable.body}}"
        }
      }
      """
    Then the response status should be 201 "Created"
    
