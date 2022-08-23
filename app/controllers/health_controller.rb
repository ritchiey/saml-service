# frozen_string_literal: true

class HealthController < ApplicationController
  skip_before_action :authenticate_subject!
  skip_after_action :ensure_access_checked

  def show; end
end
