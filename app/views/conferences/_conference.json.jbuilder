json.extract! conference, :id, :description, :name, :year, :starts_at, :ends_at, :created_at, :updated_at
json.url conference_url(conference, format: :json)