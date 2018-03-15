module Onduty
  class Stats

    def initialize(opts = { alert_limit: Onduty::Config.new.settings['alert_limit'] })
      @alert_limit = opts[:alert_limit]
    end

    def alerts_by_group(opts = {})
      aggr = [
        { "$match": {
          "created_at": {
            "$gt": Time.now - (opts[:since_days] || 30).days
          },
          "count": { "$gt": @alert_limit }
        }},
        {"$group": {
            "_id": "$group_id",
            "sum": { "$sum": 1 }
        }},
        { "$sort": { "sum":  -1 } }
      ]
      if opts[:group_id]
        aggr[0][:"$match"][:"group_id"] = BSON::ObjectId(opts[:group_id])
      end
      Onduty::Alert.collection.aggregate(aggr)
    end

    def alerts_by_group_and_day(opts = {})
      aggr = [
        { "$match": {
          "created_at": {
            "$gt": Time.now - (opts[:since_days] || 30).days
          },
          "count": { "$gt": @alert_limit }
        }},
        { "$group": {
          "_id": {
            "day": { "$dateToString": {
              format: "%Y-%m-%d", date: "$created_at" }
            }
          },
          "sum": { "$sum": 1 }
        }},
        { "$sort": { "date":  1 } }
      ]
      if opts[:group_id]
        aggr[0][:"$match"][:"group_id"] = BSON::ObjectId(opts[:group_id])
      else
        aggr[1][:"$group"][:"_id"].merge! "group_id": "$group_id"
      end
      stats = Onduty::Alert.collection.aggregate(aggr).entries.to_a
      (opts[:since_days] || 30).downto(0).each do |ago|
        date = (Time.now - ago.days)
        unless stats.find {|entry| entry["_id"]["day"] == date.strftime("%Y-%m-%d") }
          stats << {
            "_id" => { "day" => date.utc.strftime("%Y-%m-%d") },
            "sum" => 0
          }
        end
      end
      stats.sort_by {|day| day["_id"]["day"].split("-") }
    end

    def alerts_by_service(opts = {})
      Onduty::Alert.collection.aggregate([
        { "$match": {
          "created_at": {
            "$gt": Time.now - (opts[:since_days] || 30).days
          },
          "count": { "$gt": @alert_limit }
        }},
        {"$group": {
            "_id": "$name",
            "sum": { "$sum": 1 }
        }},
        { "$sort": { "sum":  -1 } },
        { "$limit": opts[:limit] || 5 }
      ])
    end

  end
end
