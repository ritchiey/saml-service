# frozen_string_literal: true

Dir['app/models/*.rb'].each { |f| File.basename(f).sub('.rb', '').camelize.constantize }
