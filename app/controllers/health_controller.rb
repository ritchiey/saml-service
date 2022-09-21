# frozen_string_literal: true

class HealthController < ApplicationController
  skip_before_action :ensure_authenticated
  skip_after_action :ensure_access_checked

  def show
    (Rails.env.production? && Redis.new.ping) && Sequel::Model.db.test_connection
  end
end
