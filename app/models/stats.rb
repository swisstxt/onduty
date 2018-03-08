module Onduty
  class Stats

    def initialize
      @alert_limit = Onduty::Config.new.settings['alert_limit']
    end

    def alerts_by_group(since_days = 7)
      Onduty::Alert.collection.aggregate([
        { "$match": {
          "created_at": { "$gt": (Time.now - since_days.days) },
          "count": { "$gt": @alert_limit }
        }},
        {"$group": {
            "_id": "$group_id",
            "sum": {"$sum": 1}
        }},
        { "$sort": { "sum":  -1 } }
      ])
    end

    def alerts_by_service(since_days = 30, limit = 5)
      Onduty::Alert.collection.aggregate([
        { "$match": {
          "created_at": { "$gt": (Time.now - since_days.days) },
          "count": { "$gt": @alert_limit }
        }},
        {"$group": {
            "_id": "$name",
            "sum": {"$sum": 1}
        }},
        { "$sort": { "sum":  -1 } },
        { "$limit": limit }
      ])
    end

  end
end
