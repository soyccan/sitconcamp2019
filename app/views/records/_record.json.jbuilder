json.extract! record, :id, :teamid, :chalid, :name, :answer, :diy, :created_at, :updated_at
json.url records_url(record, format: :json)
