module Onduty
  class Stats

    def initialize(since_days: 30, alert_count_limit: 1)
      @since_days = since_days
      @alert_count_limit = alert_count_limit
    end

    def alerts_by_group(since_days: @since_days, group_id: nil, alert_count_limit: @alert_count_limit)
      aggr = [
        { "$match": {
          "created_at": {
            "$gt": Time.now - since_days.days
          },
          "count": { "$gt": alert_count_limit }
        }},
        {"$group": {
            "_id": "$group_id",
            "sum": { "$sum": 1 }
        }},
        { "$sort": { "sum":  -1 } }
      ]
      if group_id
        aggr[0][:"$match"][:"group_id"] = BSON::ObjectId(group_id)
      end
      Onduty::Alert.collection.aggregate(aggr)
    end

    def alerts_by_hour(since_days: @since_days, alert_count_limit: @alert_count_limit)
      aggr = [
        { "$match": {
          "created_at": {
            "$gt": Time.now - since_days.days
          },
          "count": { "$gt": alert_count_limit }
        }},
        {"$group": {
            "_id": {
              "hour": { "$hour": "$created_at" }
            },
            "sum": { "$sum": 1 }
        }},
        { "$sort": { "_id":  1 } }
      ]
      Onduty::Alert.collection.aggregate(aggr)
    end

    def alerts_by_group_and_day(group_id: nil, since_days: @since_days, alert_count_limit: @alert_count_limit)
      aggr = [
        { "$match": {
          "created_at": {
            "$gt": Time.now - since_days.days
          },
          "count": { "$gt": alert_count_limit }
        }},
        { "$group": {
          "_id": {
            "day": { "$dateToString": {
              format: "%Y-%m-%d", date: "$created_at" }
            }
          },
          "sum": { "$sum": 1 }
        }},
      ]

      if group_id
        aggr[0][:"$match"][:"group_id"] = BSON::ObjectId(group_id)
      else
        aggr[1][:"$group"][:"_id"].merge!("group_id": "$group_id")
      end

      stats = Onduty::Alert.collection.aggregate(aggr).entries.to_a

      # Fill up empty days with zero values
      ids = stats.group_by {|stat| stat["_id"]['group_id'] }.keys unless group_id
      since_days.downto(0).each do |ago|
        date = Time.now - ago.days
        if group_id
          unless stats.find {|item| item["_id"]["day"] == date.strftime("%Y-%m-%d") }
            stats << {
              "_id" => { "day" => date.utc.strftime("%Y-%m-%d") },
              "sum" => 0
            }
          end
        else
          ids.each do |id|
            unless stats.find {|stat|
                stat["_id"]["day"] == date.strftime("%Y-%m-%d") && stat["_id"]["group_id"] == id }
              stats << {
                "_id" => {
                  "day" => date.utc.strftime("%Y-%m-%d"),
                  "group_id" => id
                },
                "sum" => 0
              }
            end
          end
        end
      end

      stats.sort_by {|day| day["_id"]["day"].split("-") }
    end

    def alerts_by_service(alert_limit: 5, since_days: @since_days, alert_count_limit: @alert_count_limit)
      Onduty::Alert.collection.aggregate([
        { "$match": {
          "created_at": {
            "$gt": Time.now - since_days.days
          },
          "count": { "$gt": alert_count_limit }
        }},
        {"$group": {
            "_id": "$name",
            "sum": { "$sum": 1 }
        }},
        { "$sort": { "sum":  -1 } },
        { "$limit": alert_limit }
      ])
    end

  end
end
