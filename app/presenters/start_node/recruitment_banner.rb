module StartNode
  module RecruitmentBanner
    SURVEY_URLS = {
      "/check-uk-visa" => "https://surveys.publishing.service.gov.uk/s/0DZCPX/",
    }.freeze

    def recruitment_survey_url
      SURVEY_URLS[base_path]
    end

  private

    def base_path
      "/#{@flow_presenter.name}"
    end
  end
end
