ruleset flower_shop_endpoint {
  meta {
    name "flower_shop_endpoint"
    description << A ruleset that serves as the endpoint for flower shops to talk to in the flower delivery system >>
    author "Chris Ward"
    shares __testing
    use module Subscriptions
  }

  global {
    __testing = { "events": [ { "domain": "delivery", "type": "ready",
                                "attrs": ["shopID", "dest"] },
                              { "domain": "delivery", "type": "subscribe",
                                "attrs": ["systemECI"] },
                              { "domain": "rfq", "type": "bid_available",
                                "attrs": ["shopID", "driverID"] } ] 
    }
  }

  rule report_delivery_ready {
    select when delivery ready
    foreach Subscriptions:getSubscriptions() setting (sub)
      pre {
        shopID = event:attr("shopID")
        dest = event:attr("dest")
        sub_attrs = sub{"attributes"}
      }
      if sub_attrs{"subscriber_role"} == "delivery_system" then
        event:send(
          { "eci": sub_attrs{"outbound_eci"}, "eid": "shop_message",
            "domain": "rfq", "type": "delivery_ready",
            "attrs": [shopID, dest] }
        )
      fired {}
      else {
        send_directive("ready") with
          shop = shopID
          dest = dest
      }
//    always {
//      raise rfq event "delivery_ready"
//        attributes { "shopID": shopID, "dest": dest }
//    }
  }

  rule subscribe_delivery_system {
    select when delivery subscribe
    pre{
      systemECI = event:attr("systemECI")
    }
    always {
      raise wrangler event "subscription"
         with name = "delivery_service"
         name_space = "flower_delivery"
         my_role = "flower_shop"
         subscriber_role = "delivery_system"
         channel_type = "subscription"
         subscriber_eci = systemECI
    }
  }
}