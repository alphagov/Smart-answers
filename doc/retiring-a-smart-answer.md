# How to retire a Smart Answer

At some point a request might come in for the removal of a SmartAnswer, most likely this request will include redirecting paths belonging to the identified smart answer to a new destination.

In this document is prescribed the steps that need to be taken:

- ## Remove the identified smart answer:

  Remove the following files/directory where possible:
    - Flow class files
      - lib/smart_answer_flows/<\smart-answer-name>.rb
    - ERB templates directory
      - lib/smart_answer_flows/<\smart-answer-name>
    - YAML files
      - test/data/<\smart-answer-name>-files.yml
      - test/data/<\smart-answer-name>-questions-and-responses.yml
      - test/data/<\smart-answer-name>-responses-and-expected-results.yml
      - lib/data/rates/<\smart-answer-name>.yml
      - lib/data/<\smart-answer-name>.yml
    - Regression test artefacts directory
      - test/artefacts/<\smart-answer-name>
    - Tests for Calculators, rates, data query and other ruby files
      - test/data/integration/calculators/<\smart-answer-name>_(calculator|rates_query|data_query)_test.rb
      - test/data/unit/calculators/<\smart-answer-name>_(calculator|rates_query|data_query)_test.rb
    - Calculators, data query and other ruby files
      - lib/smart_answer/calculators/<\smart-answer-name>_calculator.rb
      - lib/smart_answer/calculators/<\smart-answer-name>_data_query.rb
    - Customised start button
      - lib/smart_answer/start_button.rb
      NB: Check if the identified smart answer is listed in `custom_text_and_link` method. Remove if it exists.

  After this is done, it is very necessary to run the unit, integration and
  regression tests. It is important that you run these tests on local and in
  integration environments. If these tests pass, then proceed to the next steps.

- ## Retire and redirect the identified smart answer:

  To retire a smart answer and redirect the base_path of to a new destination,
  the retire smart answer rake task is available. It needs to be supplied a
  content-id, base_path and it's new destination.

  (i.e `retire:smart_answer[content_id,base_path,destination]`)

  The content-id for a smart answer can be found in the flow class for the smart
  answer in question. Also it can be found via the content store using the
  GOV.UK chrome extension.

  The base_path is the path belonging to the smart answer and very likely
  associated with the name of the smart_answer defined in the flow class.

  The destination is the path where this base_path of the smart asnwer should redirect to. This could be a path to a new flat content etc.

  Below is a break down of steps that make up this process.

  - ### Unpublish the identified smart answer:

    This updates the edition of a document into an unpublished state. The
    edition will be updated and removed from the live content store and
    sets it to type of gone with status 410.

    This is done via publishing-api.

  - ### Redirect smart answer paths to new destination:

    This creates a new redirect content item edition with the new destination
    and segments_mode set to ignore.

  - ### Remove smart answer content from search index:

    This the smart answer from the search index and after this has been removed
    it should no longer be discoverable via search.

- ## Retire and publish transaction format as start page:

  To retire a smart answer, retain its base_path, start page content and set
  start button link. This can be achieved by running the unpublish and
  publish_transaction rake tasks. unpublish task need to be run first.

  The unpublish rake task needs to be supplied a content-id only.

  (i.e `rake retire:unpublish[content_id]`)

  The publish_transaction rake task needs to be supplied base_path,publishing
  application (i.e publisher, smartanswers etc), title (i.e start page title),
  content (i.e start page description), link (i.e start button link/href).

  (i.e `rake retire:publish_transaction[base_path,publishing_app,title,content,link]`)

  The content-id for a smart answer can be found in the flow class for the smart
  answer in question. Also it can be found via the content store using the
  GOV.UK toolkit chrome extension.

  The base_path is the path belonging to the smart answer and very likely
  associated with the name of the smart_answer defined in the flow class.

  The title and content and link may already exist as part of the start page of the smart answer or could be supplied by the content designer.

  It is worthy of note that the title and content may contain spaces and special
  characters. It is advisable to use back slash to escape these.

  Below is a break down of steps that make up this process.

  - ### Unpublish the identified smart answer:

    This updates the edition of a document into an unpublished state. The
    edition will be updated and removed from the live content store and
    sets it to type of gone with status 410.

    This is done via publishing-api.

    (i.e `rake retire:unpublish[content_id]`)

  - ### Change publishing application

    This changes the reserve publishing application for the base path.
    Use the code below to verify the update.

    ```ruby
      PathReservation.find_by(base_path: "/base-path")
    ```

    This is done via publishing-api.

  - ### Publish transaction:

    This creates and publishes a transaction format edition to be used as the new start page in replace of the smart answer.

    This is done via publishing-api.

- ## Retire and publish answer format as start page:

  To retire a smart answer, retain its base_path and set start page content. This can be achieved by running the unpublish and
  publish_answer rake tasks. unpublish task need to be run first.

  The unpublish rake task needs to be supplied a content-id only.

  (i.e `rake retire:unpublish[content_id]`)

  The publish_answer rake task needs to be supplied base_path,publishing
  application (i.e publisher, smartanswers etc), title (i.e start page title),
  content (i.e start page description), link (i.e start button link/href).

  (i.e `rake retire:publish_answer[base_path,publishing_app,title,content]`)

  The content-id for a smart answer can be found in the flow class for the smart
  answer in question. Also it can be found via the content store using the
  GOV.UK toolkit chrome extension.

  The base_path is the path belonging to the smart answer and very likely
  associated with the name of the smart_answer defined in the flow class.

  The title and content may already exist as part of the start page of the smart answer or could be supplied by the content designer.

  It is worthy of note that the title and content may contain spaces and special
  characters. It is advisable to use back slash to escape these.

  Below is a break down of steps that make up this process.

  - ### Unpublish the identified smart answer:

    This updates the edition of a document into an unpublished state. The
    edition will be updated and removed from the live content store and
    sets it to type of gone with status 410.

    This is done via publishing-api.

    (i.e `rake retire:unpublish[content_id]`)

  - ### Change publishing application

    This changes the reserve publishing application for the base path.
    Use the code below to verify the update.

    ```ruby
      PathReservation.find_by(base_path: "/base-path")
    ```

    This is done via publishing-api.

  - ### Publish answer format:

    This creates and publishes an answer format edition to be used as the new start page in replace of the smart answer.

    This is done via publishing-api.

- ## Troubleshooting

  Below are outline some manual steps that can be taken to ensure that the
  identified smart answer is retired.

  - ### Manually updating segments mode (optional):

    Ideally, the rake tasks and calls to the publishing-api should be enough to
    retire and redirect a content item. For some unknown reasons, this process
    may require the manual update (i.e segments_mode property) of the Route
    record for the smart answer path.

    This can be achieved through the rails console for the router-api app.

    First inspect and verify that the smart answer segments_mode isn't set to
    preserved.

    **NB:**
    Login to rails console for router-api

    ```bash
      govuk_app_console router-api
    ```
    And then:

    ```ruby
      route = Route.find_by(incoming_path: "/smart-answer-base-path")
      y route # to confirm the segments_mode flag state
    ```

    **NB:** If the segments_mode is set to preserved then change it to ignore to allow the redirect to function properly for paths under the base_path, else with the preserved state it will continue to assume that the smart answer exist,
    sending requests to the smart answer controller.

    To set the segments_mode carry out the following steps.

    ```ruby
      route = Route.find_by(incoming_path: "/smart-answer-base-path")
      route.segments_mode = "ignore"
      route.save!
      RouterReloader.reload
      y route # to confirm the segments_mode flag has been updated
    ```

  - ### Reseting cache (optional):

    After rake tasks have been run, it may be important to clear the cache for the smart answer in question.

    These fabricator tasks are required:
    - `production cache.purge:"/smart-answer-base-path"`
    - `production cdn.purge_all:"/smart-answer-base-path"`
